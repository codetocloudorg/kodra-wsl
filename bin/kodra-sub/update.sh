#!/usr/bin/env bash
#
# Kodra WSL Update
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Colors
C_RESET='\033[0m'
C_GREEN='\033[0;32m'
C_CYAN='\033[0;36m'
C_WHITE='\033[1;37m'
C_GRAY='\033[0;90m'

echo ""
echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}  ${C_WHITE}Kodra WSL Update${C_RESET}                                              ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

# Update Kodra repository
echo -e "${C_WHITE}Updating Kodra WSL...${C_RESET}"
cd "$KODRA_DIR"
git fetch origin --quiet
git reset --hard origin/main --quiet
echo -e "  ${C_GREEN}✔${C_RESET} Kodra WSL updated"
echo ""

# Update system packages
echo -e "${C_WHITE}Updating system packages...${C_RESET}"
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
echo -e "  ${C_GREEN}✔${C_RESET} System packages updated"
echo ""

# Update tools
echo -e "${C_WHITE}Updating tools...${C_RESET}"

# Azure CLI
if command -v az &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating Azure CLI..."
    sudo apt-get install -y -qq azure-cli >/dev/null 2>&1
    echo -e "  ${C_GREEN}✔${C_RESET} Azure CLI"
fi

# GitHub CLI
if command -v gh &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating GitHub CLI..."
    sudo apt-get install -y -qq gh >/dev/null 2>&1
    echo -e "  ${C_GREEN}✔${C_RESET} GitHub CLI"
    
    # Update extensions
    gh extension upgrade --all 2>/dev/null || true
fi

# Starship
if command -v starship &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1
    echo -e "  ${C_GREEN}✔${C_RESET} Starship"
fi

echo ""
echo -e "${C_GREEN}Update complete!${C_RESET}"
echo ""
echo -e "  ${C_GRAY}Run 'kodra doctor' to verify all tools${C_RESET}"
echo ""
