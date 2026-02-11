#!/usr/bin/env bash
# btop - system monitor
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "btop"

if command_exists btop; then
    version=$(btop --version 2>/dev/null | head -1 | awk '{print $3}')
    show_installed "btop ($version)"
    exit 0
fi

sudo apt-get install -y -qq btop >/dev/null 2>&1

if command_exists btop; then
    version=$(btop --version 2>/dev/null | head -1 | awk '{print $3}')
    show_installed "btop ($version)"
else
    show_warn "btop installation failed"
fi
