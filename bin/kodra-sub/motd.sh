#!/usr/bin/env bash
set -e
#
# Kodra WSL MOTD — Message of the day
#
# Usage:
#   kodra motd [banner|minimal|none]
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
SETTINGS_FILE="${KODRA_CONFIG_DIR}/settings"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_motd_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra motd [banner|minimal|none]"
    echo ""
    echo -e "  ${C_BOLD}Modes:${C_RESET}"
    echo -e "    banner    Full ASCII art banner with system stats"
    echo -e "    minimal   One-line version and tool count"
    echo -e "    none      Disable MOTD display"
    echo ""
    echo -e "  ${C_DIM}Without arguments, displays MOTD using saved preference.${C_RESET}"
    echo ""
}

get_motd_mode() {
    if [ -f "${SETTINGS_FILE}" ]; then
        local mode
        mode="$(grep "^motd=" "${SETTINGS_FILE}" 2>/dev/null | cut -d= -f2)"
        echo "${mode:-banner}"
    else
        echo "banner"
    fi
}

set_motd_mode() {
    local mode="$1"
    mkdir -p "$(dirname "${SETTINGS_FILE}")"
    if [ -f "${SETTINGS_FILE}" ] && grep -q "^motd=" "${SETTINGS_FILE}" 2>/dev/null; then
        sed -i "s/^motd=.*/motd=${mode}/" "${SETTINGS_FILE}"
    else
        echo "motd=${mode}" >> "${SETTINGS_FILE}"
    fi
    show_success "MOTD mode set to: ${mode}"
}

count_installed_tools() {
    local count=0
    local tools=(
        docker az gh terraform kubectl helm k9s
        fzf bat eza zoxide rg lazygit lazydocker
        btop fastfetch yq oh-my-posh azd bicep
        pwsh opentofu copilot
    )
    for tool in "${tools[@]}"; do
        command -v "${tool}" &>/dev/null && count=$((count + 1))
    done
    echo "${count}"
}

show_motd_banner() {
    print_kodra_logo "compact"

    local ver
    if [ -f "${KODRA_DIR}/VERSION" ]; then
        ver="$(cat "${KODRA_DIR}/VERSION")"
    else
        ver="0.3.0"
    fi

    local tool_count
    tool_count="$(count_installed_tools)"

    echo ""
    print_kodra_logo
    echo ""
    echo -e "  ${C_BOLD}Kodra WSL${C_RESET} ${C_DIM}v${ver}${C_RESET}  ${C_DIM}•${C_RESET}  ${C_GREEN}${tool_count} tools${C_RESET} installed"
    echo -e "  ${C_DIM}$(uname -r) • ${USER}@$(hostname)${C_RESET}"
    echo ""
}

show_motd_minimal() {
    local ver
    if [ -f "${KODRA_DIR}/VERSION" ]; then
        ver="$(cat "${KODRA_DIR}/VERSION")"
    else
        ver="0.3.0"
    fi

    local tool_count
    tool_count="$(count_installed_tools)"

    echo -e "  ${C_DIM}Kodra WSL v${ver} • ${tool_count} tools${C_RESET}"
}

# If called with a mode argument that should be saved as preference
case "${1:-}" in
    -h|--help|help)
        show_motd_help
        ;;
    banner)
        if [ "${2:-}" = "--set" ]; then
            set_motd_mode "banner"
        else
            set_motd_mode "banner"
            show_motd_banner
        fi
        ;;
    minimal)
        if [ "${2:-}" = "--set" ]; then
            set_motd_mode "minimal"
        else
            set_motd_mode "minimal"
            show_motd_minimal
        fi
        ;;
    none)
        set_motd_mode "none"
        ;;
    "")
        local_mode="$(get_motd_mode)"
        case "${local_mode}" in
            banner)
                show_motd_banner
                ;;
            minimal)
                show_motd_minimal
                ;;
            none)
                # MOTD disabled
                ;;
        esac
        ;;
    *)
        show_error "Unknown mode: $1"
        show_motd_help
        exit 1
        ;;
esac
