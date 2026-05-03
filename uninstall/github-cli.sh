#!/usr/bin/env bash
set -e
#
# Uninstall GitHub CLI
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

TOOL_NAME="GitHub CLI"

echo -e "  ${BOX_ARROW} Removing ${C_WHITE}${TOOL_NAME}${C_RESET}..."

sudo apt-get remove -y gh 2>/dev/null || true
sudo apt-get autoremove -y 2>/dev/null || true

# Remove GitHub CLI repository and GPG key
sudo rm -f /etc/apt/sources.list.d/github-cli.list
sudo rm -f /etc/apt/keyrings/githubcli-archive-keyring.gpg

sudo apt-get update -qq 2>/dev/null || true

if ! command_exists gh; then
    echo -e "  ${BOX_CHECK} ${C_GREEN}${TOOL_NAME} removed${C_RESET}"
else
    echo -e "  ${BOX_WARN} ${C_YELLOW}${TOOL_NAME} may not be fully removed${C_RESET}"
fi
