#!/usr/bin/env bash
set -e
#
# Kodra WSL Welcome — First-run welcome screen
#
# Usage:
#   kodra welcome
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_welcome_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra welcome"
    echo ""
    echo -e "  ${C_DIM}Display the Kodra WSL welcome screen with system info and tips.${C_RESET}"
    echo ""
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

run_welcome() {
    print_kodra_logo

    local ver
    if [ -f "${KODRA_DIR}/VERSION" ]; then
        ver="$(cat "${KODRA_DIR}/VERSION")"
    else
        ver="0.3.0"
    fi

    echo ""
    echo -e "  ${C_BOLD}Welcome to Kodra WSL!${C_RESET} ${C_DIM}v${ver}${C_RESET}"
    echo -e "  ${C_DIM}Agentic Azure engineering for Windows developers${C_RESET}"
    echo ""

    # System info
    echo -e "  ${C_BOLD}System:${C_RESET}"
    local os_name
    os_name="$(lsb_release -d 2>/dev/null | cut -f2 || grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "Linux")"
    echo -e "    OS:      ${os_name}"
    echo -e "    Kernel:  $(uname -r)"
    echo -e "    Shell:   ${SHELL}"
    echo -e "    User:    ${USER}"
    if grep -qEi "(microsoft|wsl)" /proc/version 2>/dev/null; then
        echo -e "    WSL:     ${C_GREEN}Yes${C_RESET}"
    fi
    echo ""

    # Tool count
    local tool_count
    tool_count="$(count_installed_tools)"
    echo -e "  ${C_BOLD}Tools:${C_RESET} ${C_GREEN}${tool_count}${C_RESET} installed"
    echo ""

    # Quick tips
    echo -e "  ${C_BOLD}Quick Start:${C_RESET}"
    echo -e "    ${BOX_DOT} Run ${C_CYAN}kodra doctor${C_RESET} to check system health"
    echo -e "    ${BOX_DOT} Run ${C_CYAN}kodra install${C_RESET} to add more tools"
    echo -e "    ${BOX_DOT} Run ${C_CYAN}kodra menu${C_RESET} for guided interactive usage"
    echo -e "    ${BOX_DOT} Run ${C_CYAN}kodra shortcuts${C_RESET} to see available aliases"
    echo ""

    # WSL tips
    if grep -qEi "(microsoft|wsl)" /proc/version 2>/dev/null; then
        echo -e "  ${C_BOLD}WSL Tips:${C_RESET}"
        echo -e "    ${BOX_DOT} Work in ${C_WHITE}~/projects${C_RESET} for best filesystem performance"
        echo -e "    ${BOX_DOT} Open VS Code from WSL: ${C_WHITE}code .${C_RESET}"
        echo -e "    ${BOX_DOT} Docker runs natively — no Docker Desktop needed"
        echo -e "    ${BOX_DOT} Access Windows files at ${C_WHITE}/mnt/c/${C_RESET} (slower I/O)"
        echo ""
    fi
}

case "${1:-}" in
    -h|--help|help)
        show_welcome_help
        ;;
    *)
        run_welcome
        ;;
esac
