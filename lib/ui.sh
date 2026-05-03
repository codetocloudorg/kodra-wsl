#!/usr/bin/env bash
#
# Kodra WSL UI Functions
#

# Show banner
show_banner() {
    clear 2>/dev/null || true
    echo ""
    echo -e "\033[38;5;135m    ██╗  ██╗ ██████╗ ██████╗ ██████╗  █████╗\033[0m"
    echo -e "\033[38;5;141m    ██║ ██╔╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗\033[0m"
    echo -e "\033[38;5;147m    █████╔╝ ██║   ██║██║  ██║██████╔╝███████║\033[0m"
    echo -e "\033[38;5;117m    ██╔═██╗ ██║   ██║██║  ██║██╔══██╗██╔══██║\033[0m"
    echo -e "\033[38;5;87m    ██║  ██╗╚██████╔╝██████╔╝██║  ██║██║  ██║\033[0m"
    echo -e "\033[38;5;87m    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝\033[0m"
    echo ""
    echo -e "    \033[2mAgentic Azure engineering for Windows developers\033[0m"
    echo -e "    \033[2mGitHub CLI • Copilot CLI • Docker CE • Azure CLI\033[0m"
    echo ""
}

# Print KODRA logo with purple→cyan gradient
print_kodra_logo() {
    local mode="${1:-full}"
    local C_LOGO_1='\033[38;5;135m'
    local C_LOGO_2='\033[38;5;141m'
    local C_LOGO_3='\033[38;5;147m'
    local C_LOGO_4='\033[38;5;117m'
    local C_LOGO_5='\033[38;5;87m'
    local C_RST='\033[0m'

    if [ "$mode" = "compact" ]; then
        echo -e "\033[1m${C_LOGO_3}K${C_LOGO_4}O${C_LOGO_4}D${C_LOGO_5}R${C_LOGO_5}A${C_RST}"
        return
    fi

    echo -e "${C_LOGO_1}██╗  ██╗ ██████╗ ██████╗ ██████╗  █████╗${C_RST}"
    echo -e "${C_LOGO_2}██║ ██╔╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗${C_RST}"
    echo -e "${C_LOGO_3}█████╔╝ ██║   ██║██║  ██║██████╔╝███████║${C_RST}"
    echo -e "${C_LOGO_4}██╔═██╗ ██║   ██║██║  ██║██╔══██╗██╔══██║${C_RST}"
    echo -e "${C_LOGO_5}██║  ██╗╚██████╔╝██████╔╝██║  ██║██║  ██║${C_RST}"
    echo -e "${C_LOGO_5}╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝${C_RST}"
}

# Section header
section() {
    local title="$1"
    local icon="${2:-📦}"
    local box_width=40
    local content="  $icon $title"
    local content_len=${#content}
    local padding=$((box_width - content_len - 1))
    [ "$padding" -lt 1 ] && padding=1
    local pad=""
    for ((i=0; i<padding; i++)); do pad+=" "; done
    local border=""
    for ((i=0; i<box_width; i++)); do border+="${BOX_H}"; done

    echo ""
    echo -e "    ${C_CYAN}${BOX_TL}${border}${BOX_TR}${C_RESET}"
    echo -e "    ${C_CYAN}${BOX_V}${C_RESET}${content}${pad}${C_CYAN}${BOX_V}${C_RESET}"
    echo -e "    ${C_CYAN}${BOX_BL}${border}${BOX_BR}${C_RESET}"
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
    local box_w=64
    
    echo ""
    echo ""
    echo -e "    ${C_GREEN}╔════════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}$(printf ' %*s' $box_w '')${C_GREEN}║${C_RESET}"
    printf "    ${C_GREEN}║${C_RESET}   ${C_GREEN}✨ Kodra WSL installed successfully!${C_RESET}%*s${C_GREEN}║${C_RESET}\n" $((box_w - 39)) ''
    echo -e "    ${C_GREEN}║${C_RESET}$(printf ' %*s' $box_w '')${C_GREEN}║${C_RESET}"
    printf "    ${C_GREEN}║${C_RESET}   ${C_DIM}Completed in %-*s${C_RESET}${C_GREEN}║${C_RESET}\n" $((box_w - 17)) "$elapsed"
    echo -e "    ${C_GREEN}║${C_RESET}$(printf ' %*s' $box_w '')${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}╠════════════════════════════════════════════════════════════════╣${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}$(printf ' %*s' $box_w '')${C_GREEN}║${C_RESET}"
    printf "    ${C_GREEN}║${C_RESET}   ${C_CYAN}Next steps:${C_RESET}%*s${C_GREEN}║${C_RESET}\n" $((box_w - 14)) ''
    echo -e "    ${C_GREEN}║${C_RESET}$(printf ' %*s' $box_w '')${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}   ${BOX_DOT} Restart your terminal or run: ${C_WHITE}source ~/.bashrc${C_RESET}        ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}   ${BOX_DOT} Run ${C_WHITE}kodra doctor${C_RESET} to verify installation              ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}   ${BOX_DOT} Run ${C_WHITE}kodra setup${C_RESET} to configure GitHub & Azure          ${C_GREEN}║${C_RESET}"
    echo -e "    ${C_GREEN}║${C_RESET}$(printf ' %*s' $box_w '')${C_GREEN}║${C_RESET}"
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
