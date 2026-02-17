#!/usr/bin/env bash
# GitHub Copilot CLI (via npm)
# https://github.com/github/copilot-cli
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Copilot CLI"

if command_exists copilot; then
    version=$(copilot --version 2>/dev/null | head -1)
    show_installed "Copilot CLI ($version)"
    exit 0
fi

# Copilot CLI requires Node.js / npm
if ! command_exists npm; then
    show_warn "Copilot CLI requires npm (Node.js) - skipping"
    echo -e "    ${C_GRAY}Install Node.js: https://nodejs.org${C_RESET}"
    exit 0
fi

# Install via npm (global)
npm install -g @github/copilot >/dev/null 2>&1

if command_exists copilot; then
    version=$(copilot --version 2>/dev/null | head -1)
    show_installed "Copilot CLI ($version)"
    echo -e "    ${C_CYAN}ℹ${C_RESET} Run 'copilot' then '/login' to authenticate"
else
    show_warn "Copilot CLI installation failed"
fi
