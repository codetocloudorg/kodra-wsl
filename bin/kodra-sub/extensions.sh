#!/usr/bin/env bash
set -e
#
# Kodra WSL Extensions — VS Code extension management
#
# Usage:
#   kodra extensions [install|list|recommended]
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

RECOMMENDED_EXTENSIONS=(
    "ms-vscode-remote.remote-wsl"
    "ms-azuretools.vscode-docker"
    "ms-azuretools.vscode-azurefunctions"
    "ms-azuretools.vscode-bicep"
    "github.copilot"
    "github.copilot-chat"
    "github.vscode-pull-request-github"
    "hashicorp.terraform"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    "ms-vscode.azure-account"
    "redhat.vscode-yaml"
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
    "eamodio.gitlens"
    "golang.go"
    "ms-python.python"
    "rust-lang.rust-analyzer"
)

show_extensions_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra extensions [install|list|recommended]"
    echo ""
    echo -e "  ${C_BOLD}Subcommands:${C_RESET}"
    echo -e "    install       Install recommended VS Code extensions"
    echo -e "    list          Show installed extensions"
    echo -e "    recommended   Show kodra's recommended extension list"
    echo ""
}

check_code_cli() {
    if ! command_exists code; then
        show_error "VS Code CLI not found."
        echo -e "  ${C_DIM}Open VS Code from Windows, then run 'code .' from WSL to set up the CLI.${C_RESET}"
        return 1
    fi
    return 0
}

extensions_install() {
    check_code_cli || return 1

    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Installing recommended extensions..."
    echo ""

    local installed=0 failed=0
    for ext in "${RECOMMENDED_EXTENSIONS[@]}"; do
        echo -ne "    Installing ${ext}..."
        if code --install-extension "${ext}" --force &>/dev/null; then
            echo -e "\r    ${C_GREEN}${BOX_CHECK}${C_RESET} ${ext}                              "
            installed=$((installed + 1))
        else
            echo -e "\r    ${C_RED}${BOX_CROSS}${C_RESET} ${ext}                              "
            failed=$((failed + 1))
        fi
    done

    echo ""
    show_success "Installed ${installed} extensions (${failed} failed)."
}

extensions_list() {
    check_code_cli || return 1

    echo ""
    echo -e "  ${C_BOLD}Installed VS Code extensions:${C_RESET}"
    echo ""
    code --list-extensions 2>/dev/null | while IFS= read -r ext; do
        echo -e "    ${C_GREEN}${BOX_DOT}${C_RESET} ${ext}"
    done
    echo ""
}

extensions_recommended() {
    echo ""
    echo -e "  ${C_BOLD}Recommended extensions:${C_RESET}"
    echo ""
    for ext in "${RECOMMENDED_EXTENSIONS[@]}"; do
        if command_exists code && code --list-extensions 2>/dev/null | grep -qi "^${ext}$"; then
            echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} ${ext} ${C_DIM}(installed)${C_RESET}"
        else
            echo -e "    ${C_GRAY}${BOX_DOT}${C_RESET} ${ext}"
        fi
    done
    echo ""
}

case "${1:-recommended}" in
    -h|--help|help)
        show_extensions_help
        ;;
    install)
        extensions_install
        ;;
    list|ls)
        extensions_list
        ;;
    recommended|rec)
        extensions_recommended
        ;;
    *)
        show_error "Unknown subcommand: $1"
        show_extensions_help
        exit 1
        ;;
esac
