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

# Confirm prompt — returns 0 (yes) or 1 (no)
# Usage: confirm_prompt "Start installation?" [default_yes]
#   default_yes=true  → [Y/n] (Enter = yes)
#   default_yes=false → [y/N] (Enter = no)
confirm_prompt() {
    local message="$1"
    local default_yes="${2:-true}"
    local hint reply

    if [ "$default_yes" = "true" ]; then
        hint="Y/n"
    else
        hint="y/N"
    fi

    printf "    %s [%s] " "$message" "$hint"
    read -n 1 -r reply
    echo ""

    # Empty reply means user pressed Enter → use default
    if [ -z "$reply" ]; then
        [ "$default_yes" = "true" ] && return 0 || return 1
    fi

    [[ "$reply" =~ ^[Yy]$ ]] && return 0 || return 1
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

# ──────────────────────────────────────────────
# Additional UI helpers
# ──────────────────────────────────────────────

# Confirm with gum or fallback to read
confirm_installation() {
    local prompt="${1:-Proceed with installation?}"

    if command -v gum &>/dev/null; then
        gum confirm "${prompt}"
    else
        echo -ne "    ${C_CYAN}?${C_RESET} ${prompt} [y/N] "
        local answer
        read -r answer
        case "${answer}" in
            [yY]|[yY][eE][sS]) return 0 ;;
            *) return 1 ;;
        esac
    fi
}

# Format seconds as "2m 15s"
format_duration() {
    local seconds="$1"
    local mins=$((seconds / 60))
    local secs=$((seconds % 60))

    if [ "${mins}" -gt 0 ]; then
        echo "${mins}m ${secs}s"
    else
        echo "${secs}s"
    fi
}

# Show elapsed time since a timestamp
show_elapsed_time() {
    local start_time="$1"
    local now
    now="$(date +%s)"
    local elapsed=$((now - start_time))
    echo -e "    ${C_DIM}Elapsed: $(format_duration "${elapsed}")${C_RESET}"
}

# Show a progress bar
show_progress() {
    local current="$1"
    local total="$2"
    local label="${3:-Progress}"

    if command -v gum &>/dev/null && [ "${current}" -eq "${total}" ] 2>/dev/null; then
        echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} ${label} [${current}/${total}]"
        return
    fi

    local pct=0
    if [ "${total}" -gt 0 ]; then
        pct=$((current * 100 / total))
    fi
    local filled=$((pct / 5))
    local empty=$((20 - filled))

    local bar=""
    local i
    for ((i = 0; i < filled; i++)); do bar+="█"; done
    for ((i = 0; i < empty; i++)); do bar+="░"; done

    printf "\r    ${C_CYAN}%s${C_RESET} [${C_GREEN}%s${C_RESET}] %d%%  " "${label}" "${bar}" "${pct}"

    if [ "${current}" -eq "${total}" ]; then
        echo ""
    fi
}

# Show a warning box
show_warning() {
    local message="$1"
    echo -e "    ${C_YELLOW}${BOX_TL}${BOX_H}${BOX_H} ${BOX_WARN}  Warning ${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_TR}${C_RESET}"
    echo -e "    ${C_YELLOW}${BOX_V}${C_RESET} ${message}"
    echo -e "    ${C_YELLOW}${BOX_BL}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_BR}${C_RESET}"
}

# Run a command with a spinner
spin() {
    local cmd="$1"
    local message="${2:-Working...}"

    if command -v gum &>/dev/null; then
        gum spin --spinner dot --title "${message}" -- bash -c "${cmd}"
    else
        echo -ne "    ${C_CYAN}${BOX_ARROW}${C_RESET} ${message}"
        if bash -c "${cmd}" &>/dev/null; then
            echo -e "\r    ${C_GREEN}${BOX_CHECK}${C_RESET} ${message}                    "
        else
            echo -e "\r    ${C_RED}${BOX_CROSS}${C_RESET} ${message}                    "
            return 1
        fi
    fi
}

# Show a step indicator
show_step() {
    local number="$1"
    local total="$2"
    local description="$3"
    echo -e "    ${C_CYAN}[${number}/${total}]${C_RESET} ${description}"
}

# Show a centered banner line
show_banner_line() {
    local text="$1"
    local color="${2:-${C_CYAN}}"
    local cols
    cols="$(tput cols 2>/dev/null || echo 80)"
    local text_len=${#text}
    local padding=$(( (cols - text_len) / 2 ))
    [ "${padding}" -lt 0 ] && padding=0
    printf "%${padding}s" ""
    echo -e "${color}${text}${C_RESET}"
}

# Show a horizontal separator
show_separator() {
    local cols
    cols="$(tput cols 2>/dev/null || echo 80)"
    local line=""
    local i
    for ((i = 0; i < cols; i++)); do line+="${BOX_H}"; done
    echo -e "    ${C_DIM}${line}${C_RESET}"
}
