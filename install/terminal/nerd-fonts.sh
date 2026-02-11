#!/usr/bin/env bash
#
# Nerd Fonts Installation (for WSL - installs to ~/.local/share/fonts)
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Nerd Fonts"

FONTS_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONTS_DIR"

# Check if JetBrains Mono Nerd Font is installed
if ls "$FONTS_DIR"/JetBrains*.ttf &>/dev/null 2>&1; then
    show_installed "Nerd Fonts (JetBrains Mono)"
    exit 0
fi

# Download JetBrains Mono Nerd Font
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

curl -sL "$FONT_URL" -o /tmp/JetBrainsMono.tar.xz 2>/dev/null

if [ -f /tmp/JetBrainsMono.tar.xz ]; then
    tar -xJf /tmp/JetBrainsMono.tar.xz -C "$FONTS_DIR" 2>/dev/null || \
    tar -xf /tmp/JetBrainsMono.tar.xz -C "$FONTS_DIR" 2>/dev/null
    rm -f /tmp/JetBrainsMono.tar.xz
    
    # Update font cache
    if command_exists fc-cache; then
        fc-cache -f "$FONTS_DIR" 2>/dev/null
    fi
fi

# Note: In WSL, fonts should be installed on Windows for the terminal to use them
# This installs them in Linux for applications that might run graphically

show_installed "Nerd Fonts (JetBrains Mono)"
echo -e "    ${C_DIM}Note: Install fonts on Windows for Windows Terminal${C_RESET}"
