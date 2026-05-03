#!/usr/bin/env bash
set -e
#
# Kodra WSL Shortcuts — Alias and shortcut reference
#
# Usage:
#   kodra shortcuts [category]
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_shortcuts_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra shortcuts [category]"
    echo ""
    echo -e "  ${C_BOLD}Categories:${C_RESET}"
    echo -e "    git          Git aliases"
    echo -e "    docker       Docker aliases"
    echo -e "    k8s          Kubernetes aliases"
    echo -e "    azure        Azure CLI aliases"
    echo -e "    terraform    Terraform aliases"
    echo -e "    navigation   Navigation shortcuts"
    echo -e "    misc         Miscellaneous"
    echo ""
    echo -e "  ${C_DIM}Without arguments, shows all categories.${C_RESET}"
    echo ""
}

print_alias() {
    local alias_name="$1"
    local description="$2"
    printf "    ${C_CYAN}%-16s${C_RESET} %s\n" "${alias_name}" "${description}"
}

show_git_shortcuts() {
    echo -e "  ${C_BOLD}Git:${C_RESET}"
    print_alias "gs" "git status"
    print_alias "ga" "git add"
    print_alias "gc" "git commit"
    print_alias "gp" "git push"
    print_alias "gl" "git pull"
    print_alias "gd" "git diff"
    print_alias "gco" "git checkout"
    print_alias "gb" "git branch"
    print_alias "glog" "git log --oneline --graph -10"
    echo ""
}

show_docker_shortcuts() {
    echo -e "  ${C_BOLD}Docker:${C_RESET}"
    print_alias "d" "docker"
    print_alias "dc" "docker compose"
    print_alias "dps" "docker ps"
    print_alias "dpsa" "docker ps -a"
    print_alias "di" "docker images"
    print_alias "dex" "docker exec -it"
    print_alias "dlogs" "docker logs -f"
    echo ""
}

show_k8s_shortcuts() {
    echo -e "  ${C_BOLD}Kubernetes:${C_RESET}"
    print_alias "k" "kubectl"
    print_alias "kgp" "kubectl get pods"
    print_alias "kgs" "kubectl get services"
    print_alias "kgd" "kubectl get deployments"
    print_alias "kgn" "kubectl get nodes"
    print_alias "kctx" "kubectl config get-contexts"
    print_alias "kns" "set current namespace"
    echo ""
}

show_azure_shortcuts() {
    echo -e "  ${C_BOLD}Azure:${C_RESET}"
    print_alias "az-login" "az login"
    print_alias "az-sub" "show current subscription"
    print_alias "azd-up" "azd up"
    print_alias "azd-down" "azd down"
    echo ""
}

show_terraform_shortcuts() {
    echo -e "  ${C_BOLD}Terraform:${C_RESET}"
    print_alias "tf" "terraform"
    print_alias "tfi" "terraform init"
    print_alias "tfp" "terraform plan"
    print_alias "tfa" "terraform apply"
    print_alias "tfd" "terraform destroy"
    echo ""
}

show_navigation_shortcuts() {
    echo -e "  ${C_BOLD}Navigation:${C_RESET}"
    print_alias ".." "cd .."
    print_alias "..." "cd ../.."
    print_alias "...." "cd ../../.."
    print_alias "ll" "eza -la --icons --git"
    print_alias "la" "eza -a --icons"
    print_alias "lt" "eza --tree --icons -L 2"
    echo ""
}

show_misc_shortcuts() {
    echo -e "  ${C_BOLD}Miscellaneous:${C_RESET}"
    print_alias "cat" "bat --paging=never"
    print_alias "grep" "grep --color=auto"
    print_alias "df" "df -h"
    print_alias "du" "du -h"
    print_alias "free" "free -h"
    print_alias "??" "copilot -p (AI assist)"
    echo ""
}

show_all_shortcuts() {
    echo ""
    echo -e "  ${C_BOLD}Kodra WSL Shortcuts & Aliases${C_RESET}"
    echo ""
    show_git_shortcuts
    show_docker_shortcuts
    show_k8s_shortcuts
    show_azure_shortcuts
    show_navigation_shortcuts
    show_misc_shortcuts
}

case "${1:-}" in
    -h|--help|help)
        show_shortcuts_help
        ;;
    git)
        echo ""
        show_git_shortcuts
        ;;
    docker)
        echo ""
        show_docker_shortcuts
        ;;
    k8s|kubernetes)
        echo ""
        show_k8s_shortcuts
        ;;
    azure|az)
        echo ""
        show_azure_shortcuts
        ;;
    terraform|tf)
        echo ""
        show_terraform_shortcuts
        ;;
    navigation|nav)
        echo ""
        show_navigation_shortcuts
        ;;
    misc)
        echo ""
        show_misc_shortcuts
        ;;
    "")
        show_all_shortcuts
        ;;
    *)
        show_error "Unknown category: $1"
        show_shortcuts_help
        exit 1
        ;;
esac
