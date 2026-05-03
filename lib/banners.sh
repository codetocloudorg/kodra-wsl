#!/usr/bin/env bash
#
# Kodra WSL ASCII Art Banners
#
# Purple→cyan gradient branding for the WSL Edition.
#

# Gradient colors (purple → cyan)
_C_LOGO_1='\033[38;5;135m'
_C_LOGO_2='\033[38;5;141m'
_C_LOGO_3='\033[38;5;147m'
_C_LOGO_4='\033[38;5;117m'
_C_LOGO_5='\033[38;5;87m'

# Full Kodra banner with logo and tagline
show_kodra_banner() {
    echo ""
    echo -e "${_C_LOGO_1}    ██╗  ██╗ ██████╗ ██████╗ ██████╗  █████╗${C_RESET}"
    echo -e "${_C_LOGO_2}    ██║ ██╔╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗${C_RESET}"
    echo -e "${_C_LOGO_3}    █████╔╝ ██║   ██║██║  ██║██████╔╝███████║${C_RESET}"
    echo -e "${_C_LOGO_4}    ██╔═██╗ ██║   ██║██║  ██║██╔══██╗██╔══██║${C_RESET}"
    echo -e "${_C_LOGO_5}    ██║  ██╗╚██████╔╝██████╔╝██║  ██║██║  ██║${C_RESET}"
    echo -e "${_C_LOGO_5}    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝${C_RESET}"
    echo ""
    echo -e "    ${C_DIM}WSL Edition — Agentic Azure engineering${C_RESET}"
    echo ""
}

# Welcome banner (shown at start of install)
show_welcome_banner() {
    show_kodra_banner
    echo -e "    ${C_BOLD}Welcome to the Kodra WSL installer!${C_RESET}"
    echo -e "    ${C_DIM}This will set up your Azure dev environment in WSL2.${C_RESET}"
    echo ""
}

# MOTD banner (full — shown at shell startup)
show_motd_banner() {
    local version="${1:-}"
    echo ""
    echo -e "${_C_LOGO_1}    ██╗  ██╗ ██████╗ ██████╗ ██████╗  █████╗${C_RESET}"
    echo -e "${_C_LOGO_2}    ██║ ██╔╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗${C_RESET}"
    echo -e "${_C_LOGO_3}    █████╔╝ ██║   ██║██║  ██║██████╔╝███████║${C_RESET}"
    echo -e "${_C_LOGO_4}    ██╔═██╗ ██║   ██║██║  ██║██╔══██╗██╔══██║${C_RESET}"
    echo -e "${_C_LOGO_5}    ██║  ██╗╚██████╔╝██████╔╝██║  ██║██║  ██║${C_RESET}"
    echo -e "${_C_LOGO_5}    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝${C_RESET}"
    echo ""
    if [ -n "${version}" ]; then
        echo -e "    ${C_DIM}v${version} • WSL Edition • by Code To Cloud${C_RESET}"
    else
        echo -e "    ${C_DIM}WSL Edition • by Code To Cloud${C_RESET}"
    fi
    echo -e "    ${C_DIM}kodra.wsl.codetocloud.io${C_RESET}"
    echo ""
    echo -e "    ${C_DIM}Run ${C_WHITE}kodra help${C_RESET}${C_DIM} for available commands${C_RESET}"
    echo ""
}

# Minimal MOTD (one-liner)
show_minimal_motd() {
    local version="${1:-}"
    if [ -n "${version}" ]; then
        echo -e "    ${_C_LOGO_3}Kodra WSL${C_RESET} ${C_DIM}v${version}${C_RESET} ${C_DIM}— kodra help for commands${C_RESET}"
    else
        echo -e "    ${_C_LOGO_3}Kodra WSL${C_RESET} ${C_DIM}— kodra help for commands${C_RESET}"
    fi
}

# Update available banner
show_update_banner() {
    local current="${1:-}"
    local latest="${2:-}"
    echo ""
    echo -e "    ${BOX_TL}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_TR}"
    echo -e "    ${BOX_V} ${C_YELLOW}${BOX_WARN}${C_RESET}  Update available!              ${BOX_V}"
    echo -e "    ${BOX_V}    ${C_DIM}${current} → ${C_GREEN}${latest}${C_RESET}                     ${BOX_V}"
    echo -e "    ${BOX_V}    Run: ${C_WHITE}kodra update${C_RESET}               ${BOX_V}"
    echo -e "    ${BOX_BL}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_BR}"
    echo ""
}

# Completion banner (shown after successful install)
show_completion_banner() {
    local elapsed="${1:-}"
    echo ""
    echo -e "    ${C_GREEN}${BOX_TL}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_TR}${C_RESET}"
    echo -e "    ${C_GREEN}${BOX_V}${C_RESET}                                        ${C_GREEN}${BOX_V}${C_RESET}"
    echo -e "    ${C_GREEN}${BOX_V}${C_RESET}   ${C_GREEN}${BOX_CHECK}${C_RESET} Kodra WSL installed successfully!  ${C_GREEN}${BOX_V}${C_RESET}"
    echo -e "    ${C_GREEN}${BOX_V}${C_RESET}                                        ${C_GREEN}${BOX_V}${C_RESET}"
    if [ -n "${elapsed}" ]; then
        printf "    ${C_GREEN}${BOX_V}${C_RESET}   ${C_DIM}Completed in %-24s${C_RESET}${C_GREEN}${BOX_V}${C_RESET}\n" "${elapsed}"
        echo -e "    ${C_GREEN}${BOX_V}${C_RESET}                                        ${C_GREEN}${BOX_V}${C_RESET}"
    fi
    echo -e "    ${C_GREEN}${BOX_BL}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_BR}${C_RESET}"
    echo ""
}

# Error banner (shown on fatal error)
show_error_banner() {
    local message="${1:-Installation failed}"
    echo ""
    echo -e "    ${C_RED}${BOX_TL}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_TR}${C_RESET}"
    echo -e "    ${C_RED}${BOX_V}${C_RESET}                                        ${C_RED}${BOX_V}${C_RESET}"
    echo -e "    ${C_RED}${BOX_V}${C_RESET}   ${C_RED}${BOX_CROSS}${C_RESET} ${message}                     ${C_RED}${BOX_V}${C_RESET}"
    echo -e "    ${C_RED}${BOX_V}${C_RESET}                                        ${C_RED}${BOX_V}${C_RESET}"
    echo -e "    ${C_RED}${BOX_V}${C_RESET}   ${C_DIM}Check logs: ~/.config/kodra/install.log${C_RESET} ${C_RED}${BOX_V}${C_RESET}"
    echo -e "    ${C_RED}${BOX_V}${C_RESET}   ${C_DIM}Run: kodra doctor --fix${C_RESET}                 ${C_RED}${BOX_V}${C_RESET}"
    echo -e "    ${C_RED}${BOX_V}${C_RESET}                                        ${C_RED}${BOX_V}${C_RESET}"
    echo -e "    ${C_RED}${BOX_BL}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_BR}${C_RESET}"
    echo ""
}
