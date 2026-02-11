#!/usr/bin/env bash
# fastfetch - system info display
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "fastfetch"

if command_exists fastfetch; then
    version=$(fastfetch --version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "fastfetch ($version)"
    exit 0
fi

# Try PPA first
sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch >/dev/null 2>&1
sudo apt-get update -qq
sudo apt-get install -y -qq fastfetch >/dev/null 2>&1

if command_exists fastfetch; then
    version=$(fastfetch --version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "fastfetch ($version)"
else
    show_warn "fastfetch installation failed"
fi
