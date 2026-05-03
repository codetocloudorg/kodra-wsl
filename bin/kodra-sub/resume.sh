#!/usr/bin/env bash
set -e
#
# Kodra WSL Resume — Resume incomplete installation
#
# Usage:
#   kodra resume [list|run|clear]
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
STATE_FILE="${KODRA_CONFIG_DIR}/install-state"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_resume_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra resume [list|run|clear]"
    echo ""
    echo -e "  ${C_BOLD}Subcommands:${C_RESET}"
    echo -e "    list    Show which install steps completed/failed/pending"
    echo -e "    run     Re-run pending and failed steps"
    echo -e "    clear   Reset install state"
    echo ""
}

get_all_steps() {
    local install_dir="${KODRA_DIR}/install"
    for category_dir in "${install_dir}"/*/; do
        [ -d "${category_dir}" ] || continue
        for script in "${category_dir}"*.sh; do
            [ -f "${script}" ] || continue
            basename "${script}" .sh
        done
    done
}

get_step_status() {
    local step="$1"
    if [ -f "${STATE_FILE}" ]; then
        local status
        status="$(grep "^${step}=" "${STATE_FILE}" 2>/dev/null | cut -d= -f2)"
        echo "${status:-pending}"
    else
        echo "pending"
    fi
}

set_step_status() {
    local step="$1"
    local status="$2"
    mkdir -p "$(dirname "${STATE_FILE}")"
    if [ -f "${STATE_FILE}" ] && grep -q "^${step}=" "${STATE_FILE}" 2>/dev/null; then
        sed -i "s/^${step}=.*/${step}=${status}/" "${STATE_FILE}"
    else
        echo "${step}=${status}" >> "${STATE_FILE}"
    fi
}

resume_list() {
    echo ""
    echo -e "  ${C_BOLD}Installation state:${C_RESET}"
    echo ""

    local completed=0 failed=0 pending=0
    while IFS= read -r step; do
        local status
        status="$(get_step_status "${step}")"
        case "${status}" in
            done)
                echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} ${step} ${C_DIM}(completed)${C_RESET}"
                completed=$((completed + 1))
                ;;
            failed)
                echo -e "    ${C_RED}${BOX_CROSS}${C_RESET} ${step} ${C_DIM}(failed)${C_RESET}"
                failed=$((failed + 1))
                ;;
            *)
                echo -e "    ${C_GRAY}${BOX_DOT}${C_RESET} ${step} ${C_DIM}(pending)${C_RESET}"
                pending=$((pending + 1))
                ;;
        esac
    done < <(get_all_steps)

    echo ""
    echo -e "  ${C_GREEN}${completed} completed${C_RESET}  ${C_RED}${failed} failed${C_RESET}  ${C_GRAY}${pending} pending${C_RESET}"
    echo ""
}

resume_run() {
    local install_dir="${KODRA_DIR}/install"
    local ran=0

    echo -e "  ${C_CYAN}Resuming installation...${C_RESET}"
    echo ""

    while IFS= read -r step; do
        local status
        status="$(get_step_status "${step}")"
        if [ "${status}" = "done" ]; then
            continue
        fi

        local script
        script="$(find "${install_dir}" -name "${step}.sh" -type f 2>/dev/null | head -1)"
        if [ -z "${script}" ]; then
            continue
        fi

        show_installing "${step}"
        if bash "${script}" 2>/dev/null; then
            show_installed "${step}"
            set_step_status "${step}" "done"
        else
            echo -e "\r    ${C_RED}${BOX_CROSS}${C_RESET} ${step} ${C_DIM}(failed)${C_RESET}                    "
            set_step_status "${step}" "failed"
        fi
        ran=$((ran + 1))
    done < <(get_all_steps)

    if [ "${ran}" -eq 0 ]; then
        show_success "Nothing to resume — all steps completed."
    else
        echo ""
        show_success "Processed ${ran} steps."
    fi
}

resume_clear() {
    if [ -f "${STATE_FILE}" ]; then
        rm -f "${STATE_FILE}"
        show_success "Install state cleared."
    else
        show_info "No install state to clear."
    fi
}

case "${1:-list}" in
    -h|--help|help)
        show_resume_help
        ;;
    list|ls)
        resume_list
        ;;
    run)
        resume_run
        ;;
    clear|reset)
        resume_clear
        ;;
    *)
        show_error "Unknown subcommand: $1"
        show_resume_help
        exit 1
        ;;
esac
