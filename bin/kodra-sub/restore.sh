#!/usr/bin/env bash
set -e
#
# Kodra WSL Restore — Config restore (shortcut for backup restore)
#
# Usage:
#   kodra restore [backup-file]
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_restore_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra restore [backup-file]"
    echo ""
    echo -e "  ${C_DIM}If no file is specified, shows an interactive list of backups.${C_RESET}"
    echo -e "  ${C_DIM}This is a shortcut for: kodra backup restore${C_RESET}"
    echo ""
}

case "${1:-}" in
    -h|--help|help)
        show_restore_help
        ;;
    *)
        exec "${KODRA_DIR}/bin/kodra-sub/backup.sh" restore "$@"
        ;;
esac
