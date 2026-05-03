#!/usr/bin/env bash
set -e
#
# Kodra WSL Cleanup — System cleanup
#
# Usage:
#   kodra cleanup [apt|docker|logs|tmp|all]
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_cleanup_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra cleanup [apt|docker|logs|tmp|all]"
    echo ""
    echo -e "  ${C_BOLD}Targets:${C_RESET}"
    echo -e "    apt       Remove unused packages and clear apt cache"
    echo -e "    docker    Prune Docker images, containers, and volumes"
    echo -e "    logs      Rotate and truncate large log files"
    echo -e "    tmp       Clean kodra temporary files"
    echo -e "    all       Run all cleanup tasks"
    echo ""
}

bytes_to_human() {
    local bytes="$1"
    if [ "${bytes}" -ge 1073741824 ]; then
        printf "%.1fG" "$(echo "${bytes} / 1073741824" | bc -l 2>/dev/null || echo "0")"
    elif [ "${bytes}" -ge 1048576 ]; then
        printf "%.1fM" "$(echo "${bytes} / 1048576" | bc -l 2>/dev/null || echo "0")"
    elif [ "${bytes}" -ge 1024 ]; then
        printf "%.1fK" "$(echo "${bytes} / 1024" | bc -l 2>/dev/null || echo "0")"
    else
        printf "%dB" "${bytes}"
    fi
}

cleanup_apt() {
    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Cleaning apt cache..."
    local before
    before="$(du -sb /var/cache/apt 2>/dev/null | cut -f1 || echo 0)"
    sudo apt-get autoremove -y &>/dev/null || true
    sudo apt-get autoclean -y &>/dev/null || true
    sudo apt-get clean &>/dev/null || true
    local after
    after="$(du -sb /var/cache/apt 2>/dev/null | cut -f1 || echo 0)"
    local freed=$((before - after))
    [ "${freed}" -lt 0 ] && freed=0
    show_success "apt cleanup done — freed $(bytes_to_human "${freed}")"
}

cleanup_docker() {
    if ! command_exists docker; then
        show_warn "Docker is not installed."
        return 0
    fi

    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Pruning Docker..."
    local output
    output="$(docker system prune -af --volumes 2>/dev/null || echo "prune failed")"
    local reclaimed
    reclaimed="$(echo "${output}" | grep -i "reclaimed" | tail -1 || echo "")"
    if [ -n "${reclaimed}" ]; then
        show_success "Docker cleanup done — ${reclaimed}"
    else
        show_success "Docker cleanup done."
    fi
}

cleanup_logs() {
    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Cleaning log files..."
    local freed=0

    # Truncate kodra logs
    local log_dir="${KODRA_CONFIG_DIR}/logs"
    if [ -d "${log_dir}" ]; then
        for logfile in "${log_dir}"/*.log; do
            [ -f "${logfile}" ] || continue
            local size
            size="$(stat -c%s "${logfile}" 2>/dev/null || echo 0)"
            if [ "${size}" -gt 1048576 ]; then
                freed=$((freed + size))
                : > "${logfile}"
            fi
        done
    fi

    # Truncate journal logs if available
    if command_exists journalctl; then
        sudo journalctl --vacuum-time=7d &>/dev/null || true
    fi

    show_success "Log cleanup done — freed $(bytes_to_human "${freed}")"
}

cleanup_tmp() {
    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Cleaning temporary files..."
    local freed=0

    # Clean kodra temp files
    for f in /tmp/kodra-* ; do
        if [ -e "${f}" ]; then
            local size
            size="$(du -sb "${f}" 2>/dev/null | cut -f1 || echo 0)"
            freed=$((freed + size))
            rm -rf "${f}" 2>/dev/null || true
        fi
    done

    show_success "Temp cleanup done — freed $(bytes_to_human "${freed}")"
}

case "${1:-all}" in
    -h|--help|help)
        show_cleanup_help
        ;;
    apt)
        cleanup_apt
        ;;
    docker)
        cleanup_docker
        ;;
    logs)
        cleanup_logs
        ;;
    tmp)
        cleanup_tmp
        ;;
    all)
        cleanup_apt
        cleanup_docker
        cleanup_logs
        cleanup_tmp
        echo ""
        show_success "All cleanup tasks complete."
        ;;
    *)
        show_error "Unknown target: $1"
        show_cleanup_help
        exit 1
        ;;
esac
