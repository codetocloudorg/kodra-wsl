#!/usr/bin/env bash
# ripgrep - fast grep replacement
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "ripgrep"

if command_exists rg; then
    version=$(rg --version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "ripgrep ($version)"
    exit 0
fi

sudo apt-get install -y -qq ripgrep >/dev/null 2>&1

if command_exists rg; then
    version=$(rg --version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "ripgrep ($version)"
else
    show_warn "ripgrep installation failed"
fi
