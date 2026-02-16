#!/usr/bin/env bash
#
# Kodra WSL Repair
# Repairs and re-applies Kodra WSL configuration
#
# Usage:
#   kodra repair              Interactive repair (pick sections)
#   kodra repair --all        Repair everything
#   kodra repair --shell      Repair shell integration only
#   kodra repair --docker     Repair Docker only
#   kodra repair --wsl        Repair WSL config only
#   kodra repair --tools      Repair tool configs only
#   kodra repair --path       Repair PATH only
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

# Colors
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_CYAN='\033[0;36m'
C_WHITE='\033[1;37m'
C_GRAY='\033[0;90m'

REPAIR_COUNT=0
REPAIR_FAIL=0

repair_ok() {
    echo -e "  ${C_GREEN}✔${C_RESET} $1"
    ((REPAIR_COUNT++))
}

repair_fail() {
    echo -e "  ${C_RED}✖${C_RESET} $1"
    ((REPAIR_FAIL++))
}

repair_skip() {
    echo -e "  ${C_GRAY}─${C_RESET} $1 ${C_GRAY}(skipped)${C_RESET}"
}

repair_info() {
    echo -e "  ${C_CYAN}▶${C_RESET} $1"
}

# ─────────────────────────────────────────────────────────────────────────────
# Repair: Shell Integration
# ─────────────────────────────────────────────────────────────────────────────
repair_shell() {
    echo -e "${C_WHITE}Shell Integration${C_RESET}"
    echo ""

    local shell_rc=""
    if [ -f "$HOME/.bashrc" ]; then
        shell_rc="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bashrc"
        touch "$shell_rc"
    fi

    # Ensure kodra.sh config exists
    mkdir -p "$KODRA_DIR/configs/shell"
    if [ ! -f "$KODRA_DIR/configs/shell/kodra.sh" ]; then
        repair_info "Regenerating shell configuration..."
        # Source utils to get add_shell_integration
        if [ -f "$KODRA_DIR/lib/utils.sh" ]; then
            source "$KODRA_DIR/lib/utils.sh"
            add_shell_integration
            repair_ok "Shell configuration regenerated"
        else
            repair_fail "Cannot regenerate: lib/utils.sh missing"
        fi
    else
        repair_ok "Shell configuration exists"
    fi

    # Ensure kodra.sh is sourced from shell rc
    if ! grep -q "source.*kodra.sh" "$shell_rc" 2>/dev/null; then
        repair_info "Adding shell integration to $shell_rc..."
        echo "" >> "$shell_rc"
        echo "# Kodra WSL Configuration" >> "$shell_rc"
        echo "[ -f \"$KODRA_DIR/configs/shell/kodra.sh\" ] && source \"$KODRA_DIR/configs/shell/kodra.sh\"" >> "$shell_rc"
        repair_ok "Shell integration added to $(basename $shell_rc)"
    else
        repair_ok "Shell integration sourced in $(basename $shell_rc)"
    fi

    # Ensure Kodra bin is in PATH
    if ! grep -q "export PATH=\"$KODRA_DIR/bin:\$PATH\"" "$shell_rc" 2>/dev/null; then
        repair_info "Adding Kodra to PATH..."
        echo "" >> "$shell_rc"
        echo "# Kodra WSL" >> "$shell_rc"
        echo "export PATH=\"$KODRA_DIR/bin:\$PATH\"" >> "$shell_rc"
        repair_ok "Kodra added to PATH"
    else
        repair_ok "Kodra in PATH"
    fi

    # Ensure symlink exists
    if [ ! -L /usr/local/bin/kodra ] && [ ! -f /usr/local/bin/kodra ]; then
        repair_info "Creating kodra symlink..."
        sudo ln -sf "$KODRA_DIR/bin/kodra" /usr/local/bin/kodra 2>/dev/null && \
            repair_ok "Symlink created: /usr/local/bin/kodra" || \
            repair_fail "Could not create symlink (try: sudo ln -sf $KODRA_DIR/bin/kodra /usr/local/bin/kodra)"
    else
        repair_ok "Kodra symlink exists"
    fi

    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Repair: Oh My Posh / Prompt
# ─────────────────────────────────────────────────────────────────────────────
repair_prompt() {
    echo -e "${C_WHITE}Prompt (Oh My Posh)${C_RESET}"
    echo ""

    local shell_rc=""
    if [ -f "$HOME/.bashrc" ]; then
        shell_rc="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        shell_rc="$HOME/.zshrc"
    fi

    if command -v oh-my-posh &> /dev/null; then
        repair_ok "Oh My Posh installed"

        # Check if Oh My Posh init is in shell rc
        if grep -q "oh-my-posh" "$shell_rc" 2>/dev/null; then
            repair_ok "Oh My Posh initialized in $(basename $shell_rc)"
        else
            repair_info "Adding Oh My Posh initialization..."
            local theme_path="$HOME/.cache/oh-my-posh/themes"
            echo "" >> "$shell_rc"
            echo "# Oh My Posh prompt" >> "$shell_rc"
            if [ "$(basename "$SHELL")" = "zsh" ]; then
                echo 'eval "$(oh-my-posh init zsh)"' >> "$shell_rc"
            else
                echo 'eval "$(oh-my-posh init bash)"' >> "$shell_rc"
            fi
            repair_ok "Oh My Posh initialization added"
        fi
    else
        repair_info "Reinstalling Oh My Posh..."
        if curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin" >/dev/null 2>&1; then
            repair_ok "Oh My Posh reinstalled"
        else
            repair_fail "Oh My Posh reinstall failed"
        fi
    fi

    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Repair: Docker
# ─────────────────────────────────────────────────────────────────────────────
repair_docker() {
    echo -e "${C_WHITE}Docker${C_RESET}"
    echo ""

    if command -v docker &> /dev/null; then
        repair_ok "Docker installed"

        # Check daemon
        if docker info &>/dev/null; then
            repair_ok "Docker daemon running"
        else
            repair_info "Starting Docker daemon..."
            if command -v systemctl &> /dev/null && systemctl is-system-running &>/dev/null 2>&1; then
                sudo systemctl start docker 2>/dev/null
            else
                sudo service docker start 2>/dev/null
            fi
            sleep 2
            if docker info &>/dev/null; then
                repair_ok "Docker daemon started"
            else
                repair_fail "Could not start Docker daemon"
                echo -e "    ${C_GRAY}Try: sudo service docker start${C_RESET}"
            fi
        fi

        # Check user in docker group
        if groups "$USER" | grep -q docker; then
            repair_ok "User in docker group"
        else
            repair_info "Adding user to docker group..."
            sudo usermod -aG docker "$USER" 2>/dev/null && \
                repair_ok "Added to docker group (restart terminal to take effect)" || \
                repair_fail "Could not add user to docker group"
        fi

        # Check Docker socket permissions
        if [ -S /var/run/docker.sock ]; then
            repair_ok "Docker socket exists"
        else
            repair_fail "Docker socket not found (/var/run/docker.sock)"
        fi
    else
        repair_fail "Docker not installed"
        echo -e "    ${C_GRAY}Run: kodra update  or reinstall with install.sh${C_RESET}"
    fi

    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Repair: WSL Configuration
# ─────────────────────────────────────────────────────────────────────────────
repair_wsl() {
    echo -e "${C_WHITE}WSL Configuration${C_RESET}"
    echo ""

    # Only run in WSL
    if ! grep -qEi "(microsoft|wsl)" /proc/version 2>/dev/null; then
        repair_skip "Not running in WSL"
        echo ""
        return
    fi

    # Check /etc/wsl.conf
    if [ -f /etc/wsl.conf ]; then
        repair_ok "/etc/wsl.conf exists"

        # Ensure systemd is enabled
        if grep -q "systemd=true" /etc/wsl.conf; then
            repair_ok "systemd enabled"
        else
            repair_info "Enabling systemd..."
            if grep -q "\[boot\]" /etc/wsl.conf; then
                sudo sed -i '/\[boot\]/a systemd=true' /etc/wsl.conf 2>/dev/null
            else
                echo -e "\n[boot]\nsystemd=true" | sudo tee -a /etc/wsl.conf > /dev/null
            fi
            repair_ok "systemd enabled (restart WSL to take effect)"
        fi

        # Ensure interop is enabled
        if grep -q "enabled=true" /etc/wsl.conf && grep -q "\[interop\]" /etc/wsl.conf; then
            repair_ok "Windows interop enabled"
        else
            if ! grep -q "\[interop\]" /etc/wsl.conf; then
                echo -e "\n[interop]\nenabled=true\nappendWindowsPath=true" | sudo tee -a /etc/wsl.conf > /dev/null
                repair_ok "Windows interop added"
            fi
        fi
    else
        repair_info "Creating /etc/wsl.conf..."
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
        repair_ok "/etc/wsl.conf created"
    fi

    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Repair: Tool Configurations
# ─────────────────────────────────────────────────────────────────────────────
repair_tool_configs() {
    echo -e "${C_WHITE}Tool Configurations${C_RESET}"
    echo ""

    # Zoxide initialization
    local shell_rc=""
    if [ -f "$HOME/.bashrc" ]; then
        shell_rc="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        shell_rc="$HOME/.zshrc"
    fi

    if command -v zoxide &> /dev/null; then
        if grep -q "zoxide init" "$shell_rc" 2>/dev/null; then
            repair_ok "Zoxide initialized"
        else
            repair_info "Adding zoxide initialization..."
            echo "" >> "$shell_rc"
            if [ "$(basename "$SHELL")" = "zsh" ]; then
                echo 'eval "$(zoxide init zsh)"' >> "$shell_rc"
            else
                echo 'eval "$(zoxide init bash)"' >> "$shell_rc"
            fi
            repair_ok "Zoxide initialization added"
        fi
    fi

    # fzf keybindings
    if command -v fzf &> /dev/null; then
        if grep -q "fzf" "$shell_rc" 2>/dev/null; then
            repair_ok "fzf configured"
        else
            repair_ok "fzf installed (configured via kodra.sh)"
        fi
    fi

    # Kodra config directory
    mkdir -p "$KODRA_CONFIG_DIR"
    if [ ! -f "$KODRA_CONFIG_DIR/edition" ]; then
        echo "wsl" > "$KODRA_CONFIG_DIR/edition"
        repair_ok "Edition config restored"
    else
        repair_ok "Edition config exists"
    fi

    if [ ! -f "$KODRA_CONFIG_DIR/installed_at" ]; then
        date +%s > "$KODRA_CONFIG_DIR/installed_at"
        repair_ok "Install timestamp restored"
    else
        repair_ok "Install timestamp exists"
    fi

    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Repair: PATH
# ─────────────────────────────────────────────────────────────────────────────
repair_path() {
    echo -e "${C_WHITE}PATH${C_RESET}"
    echo ""

    local shell_rc=""
    if [ -f "$HOME/.bashrc" ]; then
        shell_rc="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        shell_rc="$HOME/.zshrc"
    fi

    # Common paths that should be in PATH
    local paths_to_check=(
        "$HOME/.local/bin"
        "$HOME/.fzf/bin"
        "$HOME/.azure/bin"
        "$KODRA_DIR/bin"
    )

    for dir in "${paths_to_check[@]}"; do
        if [ -d "$dir" ]; then
            if echo "$PATH" | grep -q "$dir"; then
                repair_ok "$dir in PATH"
            else
                repair_info "Adding $dir to PATH..."
                if ! grep -q "export PATH=\"$dir:\$PATH\"" "$shell_rc" 2>/dev/null && \
                   ! grep -q "export PATH=.*$dir" "$shell_rc" 2>/dev/null; then
                    echo "export PATH=\"$dir:\$PATH\"" >> "$shell_rc"
                fi
                export PATH="$dir:$PATH"
                repair_ok "$dir added to PATH"
            fi
        fi
    done

    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}  ${C_WHITE}Kodra WSL Repair${C_RESET}                                              ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

# Parse flags
REPAIR_SHELL=false
REPAIR_PROMPT=false
REPAIR_DOCKER=false
REPAIR_WSL=false
REPAIR_TOOLS=false
REPAIR_PATH=false
REPAIR_ALL=false
REPAIR_INTERACTIVE=true

for arg in "$@"; do
    case "$arg" in
        --all|-a)
            REPAIR_ALL=true
            REPAIR_INTERACTIVE=false
            ;;
        --shell|-s)
            REPAIR_SHELL=true
            REPAIR_PROMPT=true
            REPAIR_INTERACTIVE=false
            ;;
        --docker|-d)
            REPAIR_DOCKER=true
            REPAIR_INTERACTIVE=false
            ;;
        --wsl|-w)
            REPAIR_WSL=true
            REPAIR_INTERACTIVE=false
            ;;
        --tools|-t)
            REPAIR_TOOLS=true
            REPAIR_INTERACTIVE=false
            ;;
        --path|-p)
            REPAIR_PATH=true
            REPAIR_INTERACTIVE=false
            ;;
    esac
done

# Interactive mode: let user pick
if [ "$REPAIR_INTERACTIVE" = "true" ]; then
    if command -v gum &> /dev/null && [ -t 0 ]; then
        echo -e "  ${C_GRAY}(Use space to select/deselect, enter to confirm)${C_RESET}"
        echo ""
        SELECTIONS=$(gum choose --no-limit \
            --selected="Shell Integration,Prompt (Oh My Posh),Docker,WSL Configuration,Tool Configs,PATH" \
            "Shell Integration" \
            "Prompt (Oh My Posh)" \
            "Docker" \
            "WSL Configuration" \
            "Tool Configs" \
            "PATH" 2>/dev/null) || REPAIR_ALL=true

        if [ "$REPAIR_ALL" != "true" ]; then
            [[ "$SELECTIONS" == *"Shell Integration"* ]] && REPAIR_SHELL=true
            [[ "$SELECTIONS" == *"Prompt"* ]] && REPAIR_PROMPT=true
            [[ "$SELECTIONS" == *"Docker"* ]] && REPAIR_DOCKER=true
            [[ "$SELECTIONS" == *"WSL Configuration"* ]] && REPAIR_WSL=true
            [[ "$SELECTIONS" == *"Tool Configs"* ]] && REPAIR_TOOLS=true
            [[ "$SELECTIONS" == *"PATH"* ]] && REPAIR_PATH=true
        fi
    else
        REPAIR_ALL=true
    fi
fi

# Run --all
if [ "$REPAIR_ALL" = "true" ]; then
    REPAIR_SHELL=true
    REPAIR_PROMPT=true
    REPAIR_DOCKER=true
    REPAIR_WSL=true
    REPAIR_TOOLS=true
    REPAIR_PATH=true
fi

echo ""

# Execute repairs
[ "$REPAIR_SHELL" = "true" ] && repair_shell
[ "$REPAIR_PROMPT" = "true" ] && repair_prompt
[ "$REPAIR_DOCKER" = "true" ] && repair_docker
[ "$REPAIR_WSL" = "true" ] && repair_wsl
[ "$REPAIR_TOOLS" = "true" ] && repair_tool_configs
[ "$REPAIR_PATH" = "true" ] && repair_path

# Summary
echo -e "${C_CYAN}────────────────────────────────────────────────────────────────────${C_RESET}"
if [ $REPAIR_FAIL -eq 0 ]; then
    echo -e "  ${C_GREEN}Repair complete!${C_RESET} ($REPAIR_COUNT items checked/fixed)"
else
    echo -e "  ${C_GREEN}$REPAIR_COUNT repaired${C_RESET}, ${C_RED}$REPAIR_FAIL failed${C_RESET}"
fi
echo ""
echo -e "  ${C_GRAY}Restart your terminal for all changes to take effect${C_RESET}"
echo ""
