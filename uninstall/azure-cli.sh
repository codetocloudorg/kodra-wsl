#!/usr/bin/env bash
set -e
#
# Uninstall Azure CLI
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

TOOL_NAME="Azure CLI"

echo -e "  ${BOX_ARROW} Removing ${C_WHITE}${TOOL_NAME}${C_RESET}..."

sudo apt-get remove -y azure-cli 2>/dev/null || true
sudo apt-get autoremove -y 2>/dev/null || true

# Remove Microsoft repository and GPG key
sudo rm -f /etc/apt/sources.list.d/azure-cli.list
sudo rm -f /etc/apt/keyrings/microsoft.gpg
sudo rm -f /etc/apt/trusted.gpg.d/microsoft.gpg

sudo apt-get update -qq 2>/dev/null || true

if ! command_exists az; then
    echo -e "  ${BOX_CHECK} ${C_GREEN}${TOOL_NAME} removed${C_RESET}"
else
    echo -e "  ${BOX_WARN} ${C_YELLOW}${TOOL_NAME} may not be fully removed${C_RESET}"
fi
