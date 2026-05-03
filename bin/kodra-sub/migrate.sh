#!/usr/bin/env bash
set -e
#
# Kodra WSL Migrate — Version migrations
#
# Usage:
#   kodra migrate [list|run|status]
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
MIGRATIONS_DIR="${KODRA_DIR}/migrations"
MIGRATION_LOG="${KODRA_CONFIG_DIR}/migration-history"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_migrate_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra migrate [list|run|status]"
    echo ""
    echo -e "  ${C_BOLD}Subcommands:${C_RESET}"
    echo -e "    list      Show available migrations"
    echo -e "    run       Execute pending migrations"
    echo -e "    status    Show migration history"
    echo ""
}

is_migration_applied() {
    local migration="$1"
    [ -f "${MIGRATION_LOG}" ] && grep -q "^${migration}$" "${MIGRATION_LOG}" 2>/dev/null
}

migrate_list() {
    if [ ! -d "${MIGRATIONS_DIR}" ]; then
        show_info "No migrations directory found."
        return 0
    fi

    local migrations
    migrations="$(find "${MIGRATIONS_DIR}" -name "*.sh" -type f 2>/dev/null | sort)"

    if [ -z "${migrations}" ]; then
        show_info "No migrations available."
        return 0
    fi

    echo ""
    echo -e "  ${C_BOLD}Available migrations:${C_RESET}"
    echo ""
    while IFS= read -r script; do
        local name
        name="$(basename "${script}" .sh)"
        if is_migration_applied "${name}"; then
            echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} ${name} ${C_DIM}(applied)${C_RESET}"
        else
            echo -e "    ${C_YELLOW}${BOX_DOT}${C_RESET} ${name} ${C_DIM}(pending)${C_RESET}"
        fi
    done <<< "${migrations}"
    echo ""
}

migrate_run() {
    if [ ! -d "${MIGRATIONS_DIR}" ]; then
        show_info "No migrations directory found."
        return 0
    fi

    mkdir -p "$(dirname "${MIGRATION_LOG}")"
    local ran=0

    for script in "${MIGRATIONS_DIR}"/*.sh; do
        [ -f "${script}" ] || continue
        local name
        name="$(basename "${script}" .sh)"

        if is_migration_applied "${name}"; then
            continue
        fi

        echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Running migration: ${name}..."
        if bash "${script}"; then
            echo "${name}" >> "${MIGRATION_LOG}"
            show_success "Applied: ${name}"
        else
            show_error "Failed: ${name}"
            return 1
        fi
        ran=$((ran + 1))
    done

    if [ "${ran}" -eq 0 ]; then
        show_success "All migrations are up to date."
    else
        show_success "Applied ${ran} migration(s)."
    fi
}

migrate_status() {
    if [ ! -f "${MIGRATION_LOG}" ]; then
        show_info "No migrations have been applied."
        return 0
    fi

    echo ""
    echo -e "  ${C_BOLD}Migration history:${C_RESET}"
    echo ""
    while IFS= read -r name; do
        echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} ${name}"
    done < "${MIGRATION_LOG}"
    echo ""
}

case "${1:-list}" in
    -h|--help|help)
        show_migrate_help
        ;;
    list|ls)
        migrate_list
        ;;
    run)
        migrate_run
        ;;
    status)
        migrate_status
        ;;
    *)
        show_error "Unknown subcommand: $1"
        show_migrate_help
        exit 1
        ;;
esac
