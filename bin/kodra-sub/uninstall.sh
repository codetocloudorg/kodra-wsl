#!/usr/bin/env bash
set -e
#
# Kodra WSL Uninstall — Modular tool removal
#
# Usage:
#   kodra uninstall <tool-name>   Remove a specific tool
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_uninstall_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra uninstall <tool-name>"
    echo ""
    echo -e "  ${C_BOLD}Supported tools:${C_RESET}"
    echo -e "    docker, azure-cli, github-cli, terraform, opentofu"
    echo -e "    kubectl, helm, k9s, fzf, bat, eza, zoxide, ripgrep"
    echo -e "    lazygit, lazydocker, btop, fastfetch, yq, oh-my-posh"
    echo ""
}

confirm_removal() {
    local tool="$1"
    if command_exists gum; then
        gum confirm "Remove ${tool}?" || return 1
    else
        echo -ne "  Remove ${tool}? [y/N] "
        local reply
        read -r reply
        [[ "${reply}" =~ ^[Yy]$ ]] || return 1
    fi
    return 0
}

uninstall_apt_package() {
    local pkg="$1"
    if dpkg -l "${pkg}" &>/dev/null; then
        sudo apt-get remove -y "${pkg}" &>/dev/null
        sudo apt-get autoremove -y &>/dev/null
    fi
}

uninstall_tool() {
    local tool="$1"

    if ! command_exists "${tool}"; then
        show_warn "${tool} is not installed."
        return 0
    fi

    if ! confirm_removal "${tool}"; then
        echo -e "  ${C_DIM}Cancelled.${C_RESET}"
        return 0
    fi

    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Removing ${tool}..."

    case "${tool}" in
        docker)
            sudo apt-get remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &>/dev/null || true
            sudo apt-get autoremove -y &>/dev/null || true
            ;;
        azure-cli|az)
            sudo apt-get remove -y azure-cli &>/dev/null || true
            ;;
        github-cli|gh)
            sudo apt-get remove -y gh &>/dev/null || true
            ;;
        terraform)
            sudo apt-get remove -y terraform &>/dev/null || true
            rm -f "${HOME}/.local/bin/terraform" 2>/dev/null || true
            ;;
        kubectl)
            sudo apt-get remove -y kubectl &>/dev/null || true
            rm -f "${HOME}/.local/bin/kubectl" 2>/dev/null || true
            ;;
        helm)
            sudo apt-get remove -y helm &>/dev/null || true
            rm -f "${HOME}/.local/bin/helm" 2>/dev/null || true
            ;;
        k9s)
            rm -f "${HOME}/.local/bin/k9s" 2>/dev/null || true
            ;;
        fzf)
            rm -rf "${HOME}/.fzf" 2>/dev/null || true
            sudo apt-get remove -y fzf &>/dev/null || true
            ;;
        bat)
            sudo apt-get remove -y bat &>/dev/null || true
            ;;
        eza)
            sudo apt-get remove -y eza &>/dev/null || true
            ;;
        zoxide)
            rm -f "${HOME}/.local/bin/zoxide" 2>/dev/null || true
            ;;
        ripgrep|rg)
            sudo apt-get remove -y ripgrep &>/dev/null || true
            ;;
        lazygit)
            rm -f "${HOME}/.local/bin/lazygit" 2>/dev/null || true
            ;;
        lazydocker)
            rm -f "${HOME}/.local/bin/lazydocker" 2>/dev/null || true
            ;;
        btop)
            sudo apt-get remove -y btop &>/dev/null || true
            ;;
        fastfetch)
            sudo apt-get remove -y fastfetch &>/dev/null || true
            ;;
        yq)
            rm -f "${HOME}/.local/bin/yq" 2>/dev/null || true
            ;;
        oh-my-posh)
            rm -f "${HOME}/.local/bin/oh-my-posh" 2>/dev/null || true
            ;;
        *)
            show_error "No uninstall handler for: ${tool}"
            echo -e "  ${C_DIM}Try: sudo apt remove ${tool}${C_RESET}"
            exit 1
            ;;
    esac

    show_success "Removed ${tool}"
}

case "${1:-}" in
    -h|--help|help)
        show_uninstall_help
        ;;
    "")
        show_error "Please specify a tool to uninstall."
        show_uninstall_help
        exit 1
        ;;
    *)
        uninstall_tool "$1"
        ;;
esac
