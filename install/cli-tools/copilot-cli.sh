#!/usr/bin/env bash
# GitHub Copilot CLI (standalone)
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Copilot CLI"

if command_exists copilot; then
    version=$(copilot --version 2>/dev/null | head -1)
    show_installed "Copilot CLI ($version)"
    exit 0
fi

# Copilot CLI requires Homebrew
if ! command_exists brew; then
    show_warn "Copilot CLI requires Homebrew - skipping"
    echo -e "    ${C_GRAY}Install Homebrew: https://brew.sh${C_RESET}"
    exit 0
fi

# Install via Homebrew
brew install copilot-cli >/dev/null 2>&1

if command_exists copilot; then
    version=$(copilot --version 2>/dev/null | head -1)
    show_installed "Copilot CLI ($version)"
    echo -e "    ${C_CYAN}ℹ${C_RESET} Run 'copilot' then '/login' to authenticate"
else
    show_warn "Copilot CLI installation failed"
fi
