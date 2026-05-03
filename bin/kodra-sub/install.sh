#!/usr/bin/env bash
set -e
#
# Kodra WSL Install — Interactive tool installer
#
# Usage:
#   kodra install              Interactive tool selection menu
#   kodra install <tool-name>  Install a specific tool
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_install_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra install [tool-name]"
    echo ""
    echo -e "  ${C_DIM}If no tool is specified, shows an interactive selection menu.${C_RESET}"
    echo ""
    echo -e "  ${C_BOLD}Available tools:${C_RESET}"
    list_available_tools
    echo ""
}

list_available_tools() {
    local install_dir="${KODRA_DIR}/install"
    for category_dir in "${install_dir}"/*/; do
        [ -d "${category_dir}" ] || continue
        local category
        category="$(basename "${category_dir}")"
        echo -e "    ${C_CYAN}${category}:${C_RESET}"
        for script in "${category_dir}"*.sh; do
            [ -f "${script}" ] || continue
            local tool_name
            tool_name="$(basename "${script}" .sh)"
            if command_exists "${tool_name}"; then
                echo -e "      ${C_GREEN}${BOX_CHECK}${C_RESET} ${tool_name} ${C_DIM}(installed)${C_RESET}"
            else
                echo -e "      ${C_GRAY}${BOX_DOT}${C_RESET} ${tool_name}"
            fi
        done
    done
}

find_tool_script() {
    local tool="$1"
    local install_dir="${KODRA_DIR}/install"
    for category_dir in "${install_dir}"/*/; do
        local script="${category_dir}${tool}.sh"
        if [ -f "${script}" ]; then
            echo "${script}"
            return 0
        fi
    done
    return 1
}

install_tool() {
    local tool="$1"
    local script
    if ! script="$(find_tool_script "${tool}")"; then
        show_error "Unknown tool: ${tool}"
        echo ""
        echo -e "  Run ${C_CYAN}kodra install${C_RESET} to see available tools."
        exit 1
    fi

    if command_exists "${tool}"; then
        echo -e "  ${C_YELLOW}${BOX_WARN}${C_RESET} ${tool} is already installed."
        if command_exists gum; then
            if ! gum confirm "Reinstall ${tool}?"; then
                echo -e "  ${C_DIM}Skipped.${C_RESET}"
                return 0
            fi
        else
            echo -e "  ${C_DIM}Reinstalling...${C_RESET}"
        fi
    fi

    show_installing "${tool}"
    if bash "${script}"; then
        show_installed "${tool}"
    else
        show_error "Failed to install ${tool}"
        exit 1
    fi
}

run_interactive_menu() {
    local install_dir="${KODRA_DIR}/install"
    local tools=()

    for category_dir in "${install_dir}"/*/; do
        [ -d "${category_dir}" ] || continue
        for script in "${category_dir}"*.sh; do
            [ -f "${script}" ] || continue
            tools+=("$(basename "${script}" .sh)")
        done
    done

    if [ ${#tools[@]} -eq 0 ]; then
        show_error "No tools found in ${install_dir}"
        exit 1
    fi

    if command_exists gum; then
        local selected
        selected="$(printf '%s\n' "${tools[@]}" | gum choose --no-limit --header "Select tools to install:")"
        if [ -z "${selected}" ]; then
            echo -e "  ${C_DIM}No tools selected.${C_RESET}"
            return 0
        fi
        while IFS= read -r tool; do
            install_tool "${tool}"
        done <<< "${selected}"
    else
        echo -e "  ${C_BOLD}Available tools:${C_RESET}"
        list_available_tools
        echo ""
        echo -e "  ${C_DIM}Install gum for interactive selection, or run: kodra install <tool-name>${C_RESET}"
    fi
}

case "${1:-}" in
    -h|--help|help)
        show_install_help
        ;;
    "")
        run_interactive_menu
        ;;
    *)
        install_tool "$1"
        ;;
esac
