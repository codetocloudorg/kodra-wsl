#!/usr/bin/env bash
#
# Kodra WSL Uninstall Script
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

# Colors
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_CYAN='\033[0;36m'
C_WHITE='\033[1;37m'

echo ""
echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}  ${C_WHITE}Kodra WSL Uninstall${C_RESET}                                           ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

echo -e "${C_YELLOW}This will remove Kodra WSL configurations.${C_RESET}"
echo -e "${C_YELLOW}Installed tools (Docker, Azure CLI, etc.) will remain.${C_RESET}"
echo ""

read -p "    Are you sure you want to uninstall? [y/N] " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "  ${C_GREEN}Uninstall cancelled${C_RESET}"
    exit 0
fi

echo ""

# Remove kodra symlink
if [ -L /usr/local/bin/kodra ]; then
    echo -e "  ${C_CYAN}▶${C_RESET} Removing kodra command..."
    sudo rm -f /usr/local/bin/kodra
    echo -e "  ${C_GREEN}✔${C_RESET} Removed /usr/local/bin/kodra"
fi

# Remove shell integration from .zshrc
if [ -f "$HOME/.zshrc" ]; then
    echo -e "  ${C_CYAN}▶${C_RESET} Cleaning shell config..."
    sed -i '/# Kodra WSL/d' "$HOME/.zshrc" 2>/dev/null
    sed -i '/kodra.sh/d' "$HOME/.zshrc" 2>/dev/null
    sed -i '/# Auto-start Docker in WSL/d' "$HOME/.zshrc" 2>/dev/null
    sed -i '/docker-wsl-start/d' "$HOME/.zshrc" 2>/dev/null
    echo -e "  ${C_GREEN}✔${C_RESET} Cleaned .zshrc"
fi

# Remove Kodra directory
if [ -d "$KODRA_DIR" ]; then
    echo -e "  ${C_CYAN}▶${C_RESET} Removing Kodra directory..."
    rm -rf "$KODRA_DIR"
    echo -e "  ${C_GREEN}✔${C_RESET} Removed $KODRA_DIR"
fi

# Remove config directory
if [ -d "$KODRA_CONFIG_DIR" ]; then
    echo -e "  ${C_CYAN}▶${C_RESET} Removing config directory..."
    rm -rf "$KODRA_CONFIG_DIR"
    echo -e "  ${C_GREEN}✔${C_RESET} Removed $KODRA_CONFIG_DIR"
fi

# Remove docker-wsl-start helper
if [ -f "$HOME/.local/bin/docker-wsl-start" ]; then
    rm -f "$HOME/.local/bin/docker-wsl-start"
    echo -e "  ${C_GREEN}✔${C_RESET} Removed docker-wsl-start helper"
fi

echo ""
echo -e "${C_GREEN}Kodra WSL has been uninstalled.${C_RESET}"
echo ""
echo -e "  ${C_GRAY}Installed tools (Docker, Azure CLI, etc.) were not removed.${C_RESET}"
echo -e "  ${C_GRAY}To reinstall: wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash${C_RESET}"
echo ""
