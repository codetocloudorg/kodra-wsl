#!/usr/bin/env bash
set -e
#
# Kodra WSL Menu — Interactive TUI menu
#
# Usage:
#   kodra menu
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_menu_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra menu"
    echo ""
    echo -e "  ${C_DIM}Interactive TUI for navigating all kodra commands.${C_RESET}"
    echo ""
}

run_menu() {
    if ! command_exists gum; then
        show_warn "gum is required for interactive menu."
        echo -e "  ${C_DIM}Install it with: kodra install gum${C_RESET}"
        echo ""
        echo -e "  ${C_BOLD}Available commands:${C_RESET}"
        echo -e "    ${C_CYAN}🏥 Health:${C_RESET}   doctor, repair"
        echo -e "    ${C_CYAN}📦 Packages:${C_RESET} install, uninstall, update"
        echo -e "    ${C_CYAN}💾 Backup:${C_RESET}   backup, restore"
        echo -e "    ${C_CYAN}🔧 Config:${C_RESET}   setup, refresh, cleanup"
        echo -e "    ${C_CYAN}📊 Info:${C_RESET}     fetch, version, motd"
        echo -e "    ${C_CYAN}🛠️  Dev:${C_RESET}      dev, extensions, db, shortcuts"
        echo ""
        return 0
    fi

    local choice
    choice="$(gum choose \
        "🏥 doctor        — Check system health" \
        "🏥 repair        — Interactive repair menu" \
        "📦 install       — Install tools" \
        "📦 uninstall     — Remove tools" \
        "📦 update        — Update all tools" \
        "💾 backup        — Back up configs" \
        "💾 restore       — Restore configs" \
        "🔧 setup         — First-time configuration" \
        "🔧 refresh       — Refresh shell configs" \
        "🔧 cleanup       — System cleanup" \
        "📊 fetch         — System info" \
        "📊 version       — Show version" \
        "📊 motd          — Message of the day" \
        "🛠️  dev           — Dev environment setup" \
        "🛠️  extensions    — VS Code extensions" \
        "🛠️  db            — Dev database containers" \
        "🛠️  shortcuts     — Show aliases and shortcuts" \
        "❌ exit          — Exit menu" \
        --header "Kodra WSL — Select a command:" \
    )"

    local cmd
    cmd="$(echo "${choice}" | awk '{print $2}')"

    if [ "${cmd}" = "exit" ]; then
        return 0
    fi

    echo ""
    exec "${KODRA_DIR}/bin/kodra" "${cmd}"
}

case "${1:-}" in
    -h|--help|help)
        show_menu_help
        ;;
    *)
        run_menu
        ;;
esac
