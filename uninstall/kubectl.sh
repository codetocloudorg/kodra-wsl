#!/usr/bin/env bash
set -e
#
# Uninstall kubectl
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

TOOL_NAME="kubectl"

echo -e "  ${BOX_ARROW} Removing ${C_WHITE}${TOOL_NAME}${C_RESET}..."

sudo apt-get remove -y kubectl 2>/dev/null || true
sudo apt-get autoremove -y 2>/dev/null || true

# Remove Kubernetes repository and GPG key
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo apt-get update -qq 2>/dev/null || true

if ! command_exists kubectl; then
    echo -e "  ${BOX_CHECK} ${C_GREEN}${TOOL_NAME} removed${C_RESET}"
else
    echo -e "  ${BOX_WARN} ${C_YELLOW}${TOOL_NAME} may not be fully removed${C_RESET}"
fi
