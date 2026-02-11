#!/usr/bin/env bash
#
# Kodra WSL Install Script
# A Code To Cloud Project ☁️
#
# https://kodra-wsl.codetocloud.io
#
# Main installation orchestrator for WSL environments
#
# Usage:
#   ./install.sh              Normal installation (stops on error)
#   ./install.sh --debug      Debug mode (logs failures, continues)
#

# Parse arguments
export KODRA_DEBUG="false"
for arg in "$@"; do
    case $arg in
        --debug|--resilient|-d)
            export KODRA_DEBUG="true"
            shift
            ;;
    esac
done

# Only set -e if NOT in debug mode
if [ "$KODRA_DEBUG" != "true" ]; then
    set -e
fi

export KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
export KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
export KODRA_LOG_FILE="/tmp/kodra-wsl-install-$(date +%Y%m%d-%H%M%S).log"

# Start logging everything to file
exec > >(tee -a "$KODRA_LOG_FILE") 2>&1

echo "═══════════════════════════════════════════════════════════════════════════"
echo "Kodra WSL Installation Log"
echo "Started: $(date)"
echo "System: $(uname -a)"
echo "User: $USER"
echo "WSL: ${KODRA_IS_WSL:-unknown}"
echo "Log file: $KODRA_LOG_FILE"
[ "$KODRA_DEBUG" = "true" ] && echo "Mode: DEBUG (resilient - will continue on errors)"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""

# Error handler with verbose logging
kodra_error_handler() {
    local exit_code=$?
    local line_no=$1
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                         INSTALLATION ERROR                                ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "❌ Error occurred at line $line_no (exit code: $exit_code)"
    echo ""
    echo "Log file saved at: $KODRA_LOG_FILE"
    echo ""
    echo "To share this log for debugging:"
    echo "  cat $KODRA_LOG_FILE | nc termbin.com 9999"
    echo ""
    
    # Save system info
    {
        echo ""
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo "System Information at Error"
        echo "═══════════════════════════════════════════════════════════════════════════"
        echo "Ubuntu version: $(lsb_release -d 2>/dev/null || cat /etc/os-release)"
        echo "Architecture: $(uname -m)"
        echo "WSL Version: ${KODRA_WSL_VERSION:-unknown}"
        echo "Disk space: $(df -h / | tail -1)"
        echo "Memory: $(free -h | grep Mem)"
        echo "Last 50 lines of dpkg log:"
        tail -50 /var/log/dpkg.log 2>/dev/null || echo "(not available)"
    } >> "$KODRA_LOG_FILE" 2>&1
    
    exit $exit_code
}

trap 'kodra_error_handler $LINENO' ERR

# Source utility functions
source "$KODRA_DIR/lib/utils.sh"
source "$KODRA_DIR/lib/ui.sh"

# Reconnect stdin to terminal for interactive prompts
if [ ! -t 0 ] && [ -z "$KODRA_SKIP_PROMPTS" ]; then
    if ( exec 0</dev/tty ) 2>/dev/null; then
        exec < /dev/tty
    fi
fi

# Display banner
show_banner

# Initialize timing
KODRA_START_TIME=$(date +%s)
export KODRA_START_TIME

# -----------------------------------------------------------------------------
# Pre-flight checks
# -----------------------------------------------------------------------------
section "Pre-flight Checks" "🔍"

show_preflight

# Ubuntu version
ubuntu_version=$(lsb_release -rs 2>/dev/null || echo "unknown")
if [ "$ubuntu_version" != "unknown" ]; then
    version_major=$(echo "$ubuntu_version" | cut -d. -f1)
    if [ "$version_major" -ge 24 ]; then
        show_check "Ubuntu version" "ok" "$ubuntu_version"
    else
        show_check "Ubuntu version" "warn" "$ubuntu_version (24.04+ recommended)"
    fi
else
    show_check "Ubuntu version" "warn" "unknown"
fi

# WSL detection
if [ "$KODRA_IS_WSL" = "true" ]; then
    if [ "$KODRA_WSL_VERSION" = "2" ]; then
        show_check "WSL2" "ok" "Detected"
    else
        show_check "WSL" "warn" "Version $KODRA_WSL_VERSION (WSL2 recommended)"
    fi
elif [ "$KODRA_IS_AZURE_VM" = "true" ]; then
    show_check "Azure VM" "ok" "Test environment"
else
    show_check "Environment" "ok" "Native Linux"
fi

# Internet connection
if ping -c 1 github.com &> /dev/null; then
    show_check "Internet connection" "ok"
else
    show_check "Internet connection" "fail"
    end_preflight
    echo -e "    ${C_RED}No internet connection detected${C_RESET}"
    exit 1
fi

# Sudo access
if sudo -n true 2>/dev/null; then
    show_check "Sudo access" "ok"
else
    show_check "Sudo access" "fail"
    end_preflight
    echo -e "    ${C_RED}Sudo access required${C_RESET}"
    exit 1
fi

# Disk space
available_gb=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | tr -d 'G')
if [ "$available_gb" -ge 5 ]; then
    show_check "Disk space" "ok" "${available_gb}GB available"
else
    show_check "Disk space" "warn" "${available_gb}GB (5GB+ recommended)"
fi

end_preflight

# Start sudo keepalive
start_sudo_keepalive

# -----------------------------------------------------------------------------
# Install gum for beautiful CLI
# -----------------------------------------------------------------------------
install_gum

# -----------------------------------------------------------------------------
# Confirmation
# -----------------------------------------------------------------------------
section "Configuration" "⚙️"

echo ""
echo -e "    ${C_WHITE}Kodra WSL will install:${C_RESET}"
echo ""
echo -e "    ${C_CYAN}•${C_RESET} Shell environment (Zsh, Starship, aliases)"
echo -e "    ${C_CYAN}•${C_RESET} Azure tools (CLI, azd, Bicep, Terraform, OpenTofu)"
echo -e "    ${C_CYAN}•${C_RESET} Container tools (Docker CE, lazydocker)"
echo -e "    ${C_CYAN}•${C_RESET} Kubernetes tools (kubectl, Helm, k9s)"
echo -e "    ${C_CYAN}•${C_RESET} CLI utilities (bat, eza, fzf, ripgrep, etc.)"
echo -e "    ${C_CYAN}•${C_RESET} Git tools (GitHub CLI, lazygit, Copilot CLI)"
echo ""

# Skip confirmation if KODRA_SKIP_PROMPTS is set (for non-interactive installs)
if [ -z "$KODRA_SKIP_PROMPTS" ]; then
    if command -v gum &> /dev/null; then
        if ! gum confirm "Continue with installation?"; then
            echo ""
            show_info "Installation cancelled"
            exit 0
        fi
    else
        read -p "    Continue with installation? [Y/n] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo ""
            show_info "Installation cancelled"
            exit 0
        fi
    fi
fi

# -----------------------------------------------------------------------------
# System updates and base packages
# -----------------------------------------------------------------------------
section "System Updates" "📦"

show_tools_group "Preparing system environment"

show_installing "Updating package lists"
sudo apt-get update -qq
show_installed "Package lists updated"

show_installing "Upgrading system packages"
sudo apt-get upgrade -y -qq
show_installed "System packages upgraded"

show_installing "Installing base packages"
sudo apt-get install -y -qq \
    build-essential \
    curl \
    wget \
    git \
    unzip \
    zip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    jq \
    tree \
    htop \
    neofetch >/dev/null 2>&1
show_installed "Base packages ready"

# -----------------------------------------------------------------------------
# Shell Setup
# -----------------------------------------------------------------------------
section "Shell Environment" "🐚"

show_tools_group "Setting up modern shell environment"
run_installer "$KODRA_DIR/install/terminal/zsh.sh"
run_installer "$KODRA_DIR/install/terminal/starship.sh"
run_installer "$KODRA_DIR/install/terminal/nerd-fonts.sh"

# -----------------------------------------------------------------------------
# CLI Tools
# -----------------------------------------------------------------------------
section "CLI Tools" "⚡"

show_tools_group "Installing modern CLI utilities"
run_installer "$KODRA_DIR/install/cli-tools/bat.sh"
run_installer "$KODRA_DIR/install/cli-tools/eza.sh"
run_installer "$KODRA_DIR/install/cli-tools/fzf.sh"
run_installer "$KODRA_DIR/install/cli-tools/ripgrep.sh"
run_installer "$KODRA_DIR/install/cli-tools/zoxide.sh"
run_installer "$KODRA_DIR/install/cli-tools/btop.sh"
run_installer "$KODRA_DIR/install/cli-tools/fastfetch.sh"
run_installer "$KODRA_DIR/install/cli-tools/yq.sh"

# -----------------------------------------------------------------------------
# Git Tools
# -----------------------------------------------------------------------------
section "Git Tools" "🐱"

show_tools_group "Setting up Git and GitHub tools"
run_installer "$KODRA_DIR/install/cli-tools/github-cli.sh"
run_installer "$KODRA_DIR/install/cli-tools/lazygit.sh"

# -----------------------------------------------------------------------------
# Azure & Cloud Tools
# -----------------------------------------------------------------------------
section "Azure & Cloud Tools" "☁️"

show_tools_group "Installing cloud-native toolchain"
run_installer "$KODRA_DIR/install/cloud/azure-cli.sh"
run_installer "$KODRA_DIR/install/cloud/azd.sh"
run_installer "$KODRA_DIR/install/cloud/bicep.sh"
run_installer "$KODRA_DIR/install/cloud/terraform.sh"
run_installer "$KODRA_DIR/install/cloud/opentofu.sh"
run_installer "$KODRA_DIR/install/cloud/powershell.sh"

# -----------------------------------------------------------------------------
# Container Runtime (Docker CE for WSL2)
# -----------------------------------------------------------------------------
section "Container Development" "🐳"

show_tools_group "Setting up Docker CE for WSL2"
run_installer "$KODRA_DIR/install/containers/docker-ce.sh"
run_installer "$KODRA_DIR/install/containers/lazydocker.sh"

# -----------------------------------------------------------------------------
# Kubernetes Tools
# -----------------------------------------------------------------------------
section "Kubernetes" "☸️"

show_tools_group "Installing Kubernetes management tools"
run_installer "$KODRA_DIR/install/cloud/kubectl.sh"
run_installer "$KODRA_DIR/install/cloud/helm.sh"
run_installer "$KODRA_DIR/install/cloud/k9s.sh"

# -----------------------------------------------------------------------------
# Finalization
# -----------------------------------------------------------------------------
section "Finalizing" "🏁"

show_tools_group "Wrapping up installation"

# Create config directory
show_installing "Setting up configuration"
mkdir -p "$KODRA_CONFIG_DIR"
echo "wsl" > "$KODRA_CONFIG_DIR/edition"
date +%s > "$KODRA_CONFIG_DIR/installed_at"
show_installed "Configuration saved"

# Add bin to PATH
add_to_path "$KODRA_DIR/bin"

# Create symlink for kodra command
if [ ! -L /usr/local/bin/kodra ]; then
    show_installing "Creating kodra command"
    sudo ln -sf "$KODRA_DIR/bin/kodra" /usr/local/bin/kodra 2>/dev/null || true
    show_installed "kodra command available"
fi

# Add shell integration
show_installing "Shell integration"
add_shell_integration
show_installed "Shell integration configured"

# Configure WSL settings if in WSL
if [ "$KODRA_IS_WSL" = "true" ]; then
    show_installing "Configuring WSL settings"
    configure_wsl_settings
    show_installed "WSL optimized"
fi

# Show completion message
show_completion

# Save permanent log copy
PERMANENT_LOG="$KODRA_CONFIG_DIR/install.log"
cp "$KODRA_LOG_FILE" "$PERMANENT_LOG"
show_info "Log saved: ~/.config/kodra/install.log"

# Show failure summary if in debug mode
if [ "$KODRA_DEBUG" = "true" ] && [ -n "$KODRA_FAILED_INSTALLS" ]; then
    echo ""
    echo -e "    ${C_YELLOW}╔════════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "    ${C_YELLOW}║${C_RESET}  ${C_YELLOW}DEBUG: INSTALLATION SUMMARY${C_RESET}                                   ${C_YELLOW}║${C_RESET}"
    echo -e "    ${C_YELLOW}╠════════════════════════════════════════════════════════════════╣${C_RESET}"
    echo -e "    ${C_YELLOW}║${C_RESET}  Attempted: ${KODRA_INSTALL_COUNT:-0} installers                                     ${C_YELLOW}║${C_RESET}"
    echo -e "    ${C_YELLOW}║${C_RESET}  Failed: ${KODRA_FAIL_COUNT:-0} installers                                        ${C_YELLOW}║${C_RESET}"
    echo -e "    ${C_YELLOW}╠════════════════════════════════════════════════════════════════╣${C_RESET}"
    echo -e "$KODRA_FAILED_INSTALLS" | while read -r line; do
        [ -n "$line" ] && echo -e "    ${C_YELLOW}║${C_RESET}  ${C_RED}✖${C_RESET} $line"
    done
    echo -e "    ${C_YELLOW}╚════════════════════════════════════════════════════════════════╝${C_RESET}"
fi

# First-run setup
echo ""
if [ -z "$KODRA_SKIP_PROMPTS" ]; then
    if command -v gum &> /dev/null; then
        if gum confirm "Run first-time setup? (GitHub login, Azure auth, Git config)"; then
            "$KODRA_DIR/bin/kodra-sub/first-run.sh"
        else
            echo ""
            show_info "Skipped. Run 'kodra setup' anytime to configure."
        fi
    else
        read -p "    Run first-time setup? (GitHub, Azure, Git) [Y/n] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            "$KODRA_DIR/bin/kodra-sub/first-run.sh"
        else
            echo ""
            show_info "Skipped. Run 'kodra setup' anytime to configure."
        fi
    fi
else
    show_info "Skipped first-run setup. Run 'kodra setup' anytime to configure."
fi

echo ""
echo -e "    ${C_GREEN}Restart your terminal or run:${C_RESET} source ~/.zshrc"
echo ""
