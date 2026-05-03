#!/usr/bin/env bash
#
# Kodra WSL Utility Functions
#

# Colors
export C_RESET='\033[0m'
export C_RED='\033[0;31m'
export C_GREEN='\033[0;32m'
export C_YELLOW='\033[0;33m'
export C_BLUE='\033[0;34m'
export C_PURPLE='\033[0;35m'
export C_CYAN='\033[0;36m'
export C_WHITE='\033[1;37m'
export C_GRAY='\033[0;90m'
export C_DIM='\033[2m'
export C_BOLD='\033[1m'

# Box drawing characters
export BOX_TL='╭'
export BOX_TR='╮'
export BOX_BL='╰'
export BOX_BR='╯'
export BOX_H='─'
export BOX_V='│'
export BOX_CHECK='✔'
export BOX_CROSS='✖'
export BOX_WARN='⚠'
export BOX_ARROW='▶'
export BOX_DOT='•'

# Track installations
export KODRA_INSTALL_COUNT=0
export KODRA_FAIL_COUNT=0
export KODRA_FAILED_INSTALLS=""

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check Ubuntu version (24.04+)
check_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "ubuntu" ]; then
            local version_major=$(echo "$VERSION_ID" | cut -d. -f1)
            [ "$version_major" -ge 24 ]
            return $?
        fi
    fi
    return 1
}

# Check internet connection (curl first — ping/ICMP often blocked in containers/corporate)
check_internet_connection() {
    curl -fsSL --connect-timeout 5 https://github.com > /dev/null 2>&1 || \
    curl -fsSL --connect-timeout 5 https://google.com > /dev/null 2>&1 || \
    ping -c 1 -W 3 github.com &> /dev/null || \
    ping -c 1 -W 3 google.com &> /dev/null
}

# Check sudo access
check_sudo_access() {
    sudo -n true 2>/dev/null || sudo -v 2>/dev/null
}

# Run installer script with error handling
run_installer() {
    local script="$1"
    shift
    local script_name=$(basename "$script" .sh)
    
    KODRA_INSTALL_COUNT=$((KODRA_INSTALL_COUNT + 1))
    
    if [ -f "$script" ]; then
        if [ "$KODRA_DEBUG" = "true" ]; then
            # Debug mode: continue on error
            if ! bash "$script" "$@" 2>&1; then
                KODRA_FAIL_COUNT=$((KODRA_FAIL_COUNT + 1))
                KODRA_FAILED_INSTALLS="${KODRA_FAILED_INSTALLS}${script_name}\n"
                show_warn "Failed: $script_name (continuing in debug mode)"
            fi
        else
            # Normal mode: stop on error
            bash "$script" "$@"
        fi
    else
        if [ "$KODRA_DEBUG" = "true" ]; then
            KODRA_FAIL_COUNT=$((KODRA_FAIL_COUNT + 1))
            KODRA_FAILED_INSTALLS="${KODRA_FAILED_INSTALLS}${script_name} (not found)\n"
            show_warn "Script not found: $script"
        else
            echo -e "    ${C_RED}Script not found: $script${C_RESET}"
            return 1
        fi
    fi
}

# Add directory to PATH
add_to_path() {
    local dir="$1"
    local shell_rc=""
    
    # Determine shell config file (prefer .bashrc)
    if [ -f "$HOME/.bashrc" ]; then
        shell_rc="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bashrc"
    fi
    
    # Add to PATH if not already there
    if ! grep -q "export PATH=\"$dir:\$PATH\"" "$shell_rc" 2>/dev/null; then
        echo "" >> "$shell_rc"
        echo "# Kodra WSL" >> "$shell_rc"
        echo "export PATH=\"$dir:\$PATH\"" >> "$shell_rc"
    fi
    
    # Export for current session
    export PATH="$dir:$PATH"
}

# Add shell integration (aliases, completions)
add_shell_integration() {
    local shell_rc=""
    
    # Determine shell config file (prefer .bashrc)
    if [ -f "$HOME/.bashrc" ]; then
        shell_rc="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bashrc"
    fi
    
    # Create shell config if it doesn't exist
    mkdir -p "$KODRA_DIR/configs/shell"
    
    # Create kodra.sh with aliases and functions
    cat > "$KODRA_DIR/configs/shell/kodra.sh" << 'KODRA_SHELL'
# Kodra WSL Shell Configuration

# Aliases
alias ll='eza -la --icons --git 2>/dev/null || ls -la'
alias la='eza -a --icons 2>/dev/null || ls -a'
alias lt='eza --tree --icons -L 2 2>/dev/null || tree -L 2'
alias cat='bat --paging=never 2>/dev/null || cat'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate -10'

# Docker aliases
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kctx='kubectl config get-contexts'
alias kns='kubectl config set-context --current --namespace'

# Azure aliases
alias az-login='az login'
alias az-sub='az account show --query name -o tsv'
alias azd-up='azd up'
alias azd-down='azd down'

# Copilot CLI aliases
alias '??'='copilot -p'
alias 'explain'='copilot -p "Explain this command:"'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Editor
export EDITOR='code --wait'
export VISUAL='code --wait'

# FZF configuration
if command -v fzf &> /dev/null; then
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    fi
fi

# Note: Zoxide and Oh My Posh are initialized directly in .bashrc/.zshrc
# by the oh-my-posh.sh installer with the correct shell syntax

# Oh My Posh prompt (configured in oh-my-posh.sh, sourced from .bashrc)
KODRA_SHELL

    # Source kodra.sh from shell config
    if ! grep -q "source.*kodra.sh" "$shell_rc" 2>/dev/null; then
        echo "" >> "$shell_rc"
        echo "# Kodra WSL Configuration" >> "$shell_rc"
        echo "[ -f \"$KODRA_DIR/configs/shell/kodra.sh\" ] && source \"$KODRA_DIR/configs/shell/kodra.sh\"" >> "$shell_rc"
    fi
}

# Configure WSL-specific settings
configure_wsl_settings() {
    # Create/update /etc/wsl.conf for systemd and other settings
    if [ ! -f /etc/wsl.conf ]; then
        sudo tee /etc/wsl.conf > /dev/null << 'WSLCONF'
[boot]
systemd=true

[interop]
enabled=true
appendWindowsPath=true

[automount]
enabled=true
options="metadata,umask=22,fmask=11"
mountFsTab=true

[network]
generateHosts=true
generateResolvConf=true
WSLCONF
    else
        # Ensure systemd is enabled
        if ! grep -q "systemd=true" /etc/wsl.conf 2>/dev/null; then
            if grep -q "\[boot\]" /etc/wsl.conf; then
                sudo sed -i '/\[boot\]/a systemd=true' /etc/wsl.conf
            else
                echo -e "\n[boot]\nsystemd=true" | sudo tee -a /etc/wsl.conf > /dev/null
            fi
        fi
    fi
}

# Start sudo keepalive (prevents password prompts during install)
start_sudo_keepalive() {
    # Validate sudo access (works with both password and passwordless sudo)
    sudo -n true 2>/dev/null || sudo -v 2>/dev/null || true
    
    # Keep sudo alive in background
    (
        while true; do
            sudo -n true
            sleep 50
            kill -0 "$$" 2>/dev/null || exit
        done
    ) &
    SUDO_KEEPALIVE_PID=$!
    export SUDO_KEEPALIVE_PID
}

# Stop sudo keepalive
stop_sudo_keepalive() {
    if [ -n "$SUDO_KEEPALIVE_PID" ]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    fi
}

# Calculate elapsed time
elapsed_time() {
    local start=$KODRA_START_TIME
    local now=$(date +%s)
    local elapsed=$((now - start))
    local mins=$((elapsed / 60))
    local secs=$((elapsed % 60))
    
    if [ $mins -gt 0 ]; then
        echo "${mins}m ${secs}s"
    else
        echo "${secs}s"
    fi
}

# Cleanup handler
cleanup_on_exit() {
    stop_sudo_keepalive
}

trap 'cleanup_on_exit' EXIT

# ──────────────────────────────────────────────
# Additional utility helpers
# ──────────────────────────────────────────────

# Create directory with error handling
ensure_dir() {
    local path="$1"
    if [ -z "${path}" ]; then
        echo -e "    ${C_RED}${BOX_CROSS}${C_RESET} ensure_dir: path required" >&2
        return 1
    fi
    if [ ! -d "${path}" ]; then
        mkdir -p "${path}" || {
            echo -e "    ${C_RED}${BOX_CROSS}${C_RESET} Failed to create directory: ${path}" >&2
            return 1
        }
    fi
}

# Get latest release tag from GitHub
get_github_release() {
    local owner="$1"
    local repo="$2"

    local tag
    tag="$(curl -fsSL "https://api.github.com/repos/${owner}/${repo}/releases/latest" 2>/dev/null \
        | grep '"tag_name"' | head -1 | cut -d'"' -f4)"

    if [ -n "${tag}" ]; then
        echo "${tag}"
    else
        return 1
    fi
}

# Download and install a .deb package
install_deb() {
    local url="$1"
    local workdir="${HOME}/.cache/kodra/downloads"
    mkdir -p "${workdir}"

    local filename
    filename="$(basename "${url}")"
    curl -fsSL -o "${workdir}/${filename}" "${url}" || return 1
    sudo dpkg -i "${workdir}/${filename}" 2>&1 || sudo apt-get install -f -y -qq 2>&1
    rm -f "${workdir}/${filename}"
}

# Append to the install log file
log_to_file() {
    local level="$1"
    local message="$2"
    local log_file="${HOME}/.config/kodra/install.log"
    local timestamp
    timestamp="$(date +%Y-%m-%dT%H:%M:%S%z)"

    mkdir -p "$(dirname "${log_file}")"
    printf '[%s] %-5s %s\n' "${timestamp}" "${level}" "${message}" >> "${log_file}"
}

# Check if running in WSL (return 0 if yes)
is_wsl() {
    grep -qEi '(microsoft|wsl)' /proc/version 2>/dev/null
}

# Check specifically for WSL2 (return 0 if yes)
is_wsl2() {
    if grep -qEi '(microsoft|wsl)' /proc/version 2>/dev/null; then
        grep -qi 'microsoft-standard' /proc/version 2>/dev/null && return 0
        [ -f /proc/sys/fs/binfmt_misc/WSLInterop ] && return 0
    fi
    return 1
}

# Read the VERSION file
get_kodra_version() {
    local version_file="${KODRA_DIR:-${HOME}/.kodra}/VERSION"
    if [ -f "${version_file}" ]; then
        cat "${version_file}"
    else
        echo "unknown"
    fi
}
