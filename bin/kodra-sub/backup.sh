#!/usr/bin/env bash
set -e
#
# Kodra WSL Backup — Config backup and restore
#
# Usage:
#   kodra backup [create|list|restore|delete]
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
BACKUP_DIR="${KODRA_CONFIG_DIR}/backups"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_backup_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra backup [create|list|restore|delete]"
    echo ""
    echo -e "  ${C_BOLD}Subcommands:${C_RESET}"
    echo -e "    create    Create a new config backup"
    echo -e "    list      Show available backups"
    echo -e "    restore   Restore from a backup"
    echo -e "    delete    Remove old backups"
    echo ""
}

backup_create() {
    mkdir -p "${BACKUP_DIR}"
    local timestamp
    timestamp="$(date +%Y%m%d-%H%M%S)"
    local backup_file="${BACKUP_DIR}/kodra-backup-${timestamp}.tar.gz"

    local files_to_backup=()
    for f in "${HOME}/.bashrc" "${HOME}/.profile" "${HOME}/.inputrc" "${HOME}/.gitconfig"; do
        [ -f "${f}" ] && files_to_backup+=("${f}")
    done
    [ -d "${KODRA_CONFIG_DIR}" ] && files_to_backup+=("${KODRA_CONFIG_DIR}")
    [ -d "${KODRA_DIR}/configs" ] && files_to_backup+=("${KODRA_DIR}/configs")

    local omp_config="${HOME}/.config/oh-my-posh"
    [ -d "${omp_config}" ] && files_to_backup+=("${omp_config}")

    if [ ${#files_to_backup[@]} -eq 0 ]; then
        show_warn "No config files found to back up."
        return 1
    fi

    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Creating backup..."
    tar czf "${backup_file}" "${files_to_backup[@]}" 2>/dev/null || true

    local size
    size="$(du -h "${backup_file}" | cut -f1)"
    show_success "Backup created: ${backup_file} (${size})"
}

backup_list() {
    mkdir -p "${BACKUP_DIR}"
    local backups
    backups="$(find "${BACKUP_DIR}" -name "kodra-backup-*.tar.gz" -type f 2>/dev/null | sort -r)"

    if [ -z "${backups}" ]; then
        show_info "No backups found."
        return 0
    fi

    echo ""
    echo -e "  ${C_BOLD}Available backups:${C_RESET}"
    echo ""
    while IFS= read -r f; do
        local name size date_str
        name="$(basename "${f}")"
        size="$(du -h "${f}" | cut -f1)"
        date_str="$(stat -c '%y' "${f}" 2>/dev/null | cut -d. -f1)"
        echo -e "    ${C_CYAN}${BOX_DOT}${C_RESET} ${name}  ${C_DIM}${size}  ${date_str}${C_RESET}"
    done <<< "${backups}"
    echo ""
}

backup_restore() {
    local backup_file="$1"

    if [ -z "${backup_file}" ]; then
        local backups
        backups="$(find "${BACKUP_DIR}" -name "kodra-backup-*.tar.gz" -type f 2>/dev/null | sort -r)"

        if [ -z "${backups}" ]; then
            show_info "No backups found."
            return 0
        fi

        if command_exists gum; then
            backup_file="$(echo "${backups}" | xargs -I{} basename {} | gum choose --header "Select backup to restore:")"
            backup_file="${BACKUP_DIR}/${backup_file}"
        else
            echo -e "  ${C_BOLD}Available backups:${C_RESET}"
            local i=1
            local backup_arr=()
            while IFS= read -r f; do
                backup_arr+=("${f}")
                echo -e "    ${i}) $(basename "${f}")"
                i=$((i + 1))
            done <<< "${backups}"
            echo -ne "  Select backup number: "
            local choice
            read -r choice
            backup_file="${backup_arr[$((choice - 1))]}"
        fi
    fi

    if [ ! -f "${backup_file}" ]; then
        show_error "Backup not found: ${backup_file}"
        return 1
    fi

    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Restoring from $(basename "${backup_file}")..."
    tar xzf "${backup_file}" -C / 2>/dev/null || tar xzf "${backup_file}" -C "${HOME}" 2>/dev/null || true
    show_success "Backup restored."
}

backup_delete() {
    local backups
    backups="$(find "${BACKUP_DIR}" -name "kodra-backup-*.tar.gz" -type f 2>/dev/null | sort -r)"

    if [ -z "${backups}" ]; then
        show_info "No backups to delete."
        return 0
    fi

    if command_exists gum; then
        local selected
        selected="$(echo "${backups}" | xargs -I{} basename {} | gum choose --no-limit --header "Select backups to delete:")"
        if [ -z "${selected}" ]; then
            echo -e "  ${C_DIM}No backups selected.${C_RESET}"
            return 0
        fi
        while IFS= read -r name; do
            rm -f "${BACKUP_DIR}/${name}"
            show_success "Deleted ${name}"
        done <<< "${selected}"
    else
        backup_list
        echo -ne "  Delete all backups? [y/N] "
        local reply
        read -r reply
        if [[ "${reply}" =~ ^[Yy]$ ]]; then
            rm -f "${BACKUP_DIR}"/kodra-backup-*.tar.gz
            show_success "All backups deleted."
        fi
    fi
}

case "${1:-create}" in
    -h|--help|help)
        show_backup_help
        ;;
    create)
        backup_create
        ;;
    list|ls)
        backup_list
        ;;
    restore)
        backup_restore "${2:-}"
        ;;
    delete|rm)
        backup_delete
        ;;
    *)
        show_error "Unknown subcommand: $1"
        show_backup_help
        exit 1
        ;;
esac
