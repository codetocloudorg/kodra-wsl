#!/usr/bin/env bash
#
# Kodra WSL UI Functions
#

# Show banner
show_banner() {
    clear 2>/dev/null || true
    echo ""
    echo -e "\033[38;5;208m    ██╗  ██╗ ██████╗ ██████╗ ██████╗  █████╗     ██╗    ██╗███████╗██╗     \033[0m"
    echo -e "\033[38;5;214m    ██║ ██╔╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗    ██║    ██║██╔════╝██║     \033[0m"
    echo -e "\033[38;5;39m    █████╔╝ ██║   ██║██║  ██║██████╔╝███████║    ██║ █╗ ██║███████╗██║     \033[0m"
    echo -e "\033[38;5;33m    ██╔═██╗ ██║   ██║██║  ██║██╔══██╗██╔══██║    ██║███╗██║╚════██║██║     \033[0m"
    echo -e "\033[38;5;27m    ██║  ██╗╚██████╔╝██████╔╝██║  ██║██║  ██║    ╚███╔███╔╝███████║███████╗\033[0m"
    echo -e "\033[38;5;21m    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚══╝╚══╝ ╚══════╝╚══════╝\033[0m"
    echo ""
    echo -e "    ${C_GRAY}Agentic Azure engineering for Windows developers${C_RESET}"
    echo ""
}

# Section header
section() {
    local title="$1"
    local icon="${2:-📦}"
    
    echo ""
    echo -e "    ${C_CYAN}${BOX_TL}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_TR}${C_RESET}"
    echo -e "    ${C_CYAN}${BOX_V}${C_RESET}  $icon ${C_WHITE}${C_BOLD}$title${C_RESET}"
    echo -e "    ${C_CYAN}${BOX_BL}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_BR}${C_RESET}"
    echo ""
}

# Tools group header
show_tools_group() {
    local description="$1"
    echo -e "    ${C_DIM}$description${C_RESET}"
    echo ""
}

# Show preflight check header
show_preflight() {
    echo ""
    echo -e "    ${C_CYAN}Checking system requirements...${C_RESET}"
    echo ""
}

# Show preflight check result
show_check() {
    local name="$1"
    local status="$2"
    local detail="${3:-}"
    
    case "$status" in
        ok)
            echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} $name ${C_DIM}$detail${C_RESET}"
            ;;
        warn)
            echo -e "    ${C_YELLOW}${BOX_WARN}${C_RESET} $name ${C_DIM}$detail${C_RESET}"
            ;;
        fail)
            echo -e "    ${C_RED}${BOX_CROSS}${C_RESET} $name ${C_DIM}$detail${C_RESET}"
            ;;
    esac
}

# End preflight section
end_preflight() {
    echo ""
}

# Show installing status
show_installing() {
    local name="$1"
    echo -ne "    ${C_CYAN}${BOX_ARROW}${C_RESET} Installing $name..."
}

# Show installed status
show_installed() {
    local name="$1"
    echo -e "\r    ${C_GREEN}${BOX_CHECK}${C_RESET} $name                              "
}

# Show success message
show_success() {
    local message="$1"
    echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} $message"
}

# Show info message
show_info() {
    local message="$1"
    echo -e "    ${C_CYAN}ℹ${C_RESET} $message"
}

# Show warning message
show_warn() {
    local message="$1"
    echo -e "    ${C_YELLOW}${BOX_WARN}${C_RESET} $message"
}

# Show error message
show_error() {
    local message="$1"
    echo -e "    ${C_RED}${BOX_CROSS}${C_RESET} $message"
}

# Install gum for better CLI prompts
install_gum() {
    if ! command_exists gum; then
        echo -e "    ${C_CYAN}${BOX_ARROW}${C_RESET} Installing gum (CLI prompt utility)..."
        
        # Try to install gum
        if command_exists brew; then
            brew install gum >/dev/null 2>&1 || true
        else
            # Install from GitHub releases
            GUM_VERSION="0.13.0"
            ARCH=$(dpkg --print-architecture)
            
            # Download and install
            wget -qO /tmp/gum.deb "https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_${ARCH}.deb" 2>/dev/null || true
            if [ -f /tmp/gum.deb ]; then
                sudo dpkg -i /tmp/gum.deb >/dev/null 2>&1 || true
                rm -f /tmp/gum.deb
            fi
        fi
        
        if command_exists gum; then
            echo -e "\r    ${C_GREEN}${BOX_CHECK}${C_RESET} gum installed                              "
        else
            echo -e "\r    ${C_YELLOW}${BOX_WARN}${C_RESET} gum not available (using fallback prompts) "
        fi
    fi
}

# Show completion message
show_completion() {
    local elapsed=$(elapsed_time)
    
    echo ""
    echo ""
    echo -e "    ${C_GREEN}╔════════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}                                                                ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}   ${C_GREEN}✨ Kodra WSL installed successfully!${C_RESET}                        ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}                                                                ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}   ${C_DIM}Completed in $elapsed${C_RESET}                                         ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}                                                                ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}╠════════════════════════════════════════════════════════════════╣${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}                                                                ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}   ${C_CYAN}Next steps:${C_RESET}                                                  ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}                                                                ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}   ${BOX_DOT} Restart your terminal or run: ${C_WHITE}source ~/.bashrc${C_RESET}        ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}   ${BOX_DOT} Run ${C_WHITE}kodra doctor${C_RESET} to verify installation              ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}   ${BOX_DOT} Run ${C_WHITE}kodra setup${C_RESET} to configure GitHub & Azure          ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}                                                                ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}╚════════════════════════════════════════════════════════════════╝${C_RESET}"
    echo ""
    
    # Show WSL-specific tips
    if [ "$KODRA_IS_WSL" = "true" ]; then
        echo -e "    ${C_CYAN}WSL Tips:${C_RESET}"
        echo -e "    ${BOX_DOT} Work in Linux filesystem for best performance: ${C_WHITE}~/projects${C_RESET}"
        echo -e "    ${BOX_DOT} Open VS Code from WSL: ${C_WHITE}code .${C_RESET}"
        echo -e "    ${BOX_DOT} Docker is ready: ${C_WHITE}docker run hello-world${C_RESET}"
        echo ""
    fi
}
