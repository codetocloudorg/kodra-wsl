#!/usr/bin/env bash
set -e
#
# Kodra WSL Refresh — Refresh shell configs
#
# Usage:
#   kodra refresh [aliases|completions|prompt|all]
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_refresh_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra refresh [aliases|completions|prompt|all]"
    echo ""
    echo -e "  ${C_BOLD}Targets:${C_RESET}"
    echo -e "    aliases       Re-deploy shell aliases from kodra configs"
    echo -e "    completions   Refresh shell completions"
    echo -e "    prompt        Refresh Oh My Posh prompt config"
    echo -e "    all           Refresh everything"
    echo ""
}

refresh_aliases() {
    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Refreshing aliases..."
    local src="${KODRA_DIR}/configs/shell/kodra.sh"
    if [ -f "${src}" ]; then
        # Re-source to verify it loads
        # shellcheck disable=SC1090
        source "${src}" 2>/dev/null || true
        show_success "Aliases refreshed from ${src}"
    else
        show_warn "No alias config found at ${src}"
    fi
}

refresh_completions() {
    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Refreshing completions..."
    local completions_dir="${KODRA_DIR}/configs/completions"
    if [ -d "${completions_dir}" ]; then
        for f in "${completions_dir}"/*; do
            [ -f "${f}" ] || continue
            # shellcheck disable=SC1090
            source "${f}" 2>/dev/null || true
        done
        show_success "Completions refreshed."
    else
        show_info "No completions directory found."
    fi
}

refresh_prompt() {
    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Refreshing prompt config..."
    local omp_src="${KODRA_DIR}/configs/oh-my-posh"
    local omp_dest="${HOME}/.config/oh-my-posh"
    if [ -d "${omp_src}" ]; then
        mkdir -p "${omp_dest}"
        cp -r "${omp_src}"/* "${omp_dest}/" 2>/dev/null || true
        show_success "Oh My Posh config refreshed."
    else
        show_info "No Oh My Posh config found in kodra configs."
    fi
}

case "${1:-all}" in
    -h|--help|help)
        show_refresh_help
        ;;
    aliases)
        refresh_aliases
        ;;
    completions)
        refresh_completions
        ;;
    prompt)
        refresh_prompt
        ;;
    all)
        refresh_aliases
        refresh_completions
        refresh_prompt
        echo ""
        show_success "All configs refreshed. Run 'source ~/.bashrc' to apply."
        ;;
    *)
        show_error "Unknown target: $1"
        show_refresh_help
        exit 1
        ;;
esac
