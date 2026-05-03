#!/usr/bin/env bash
set -e
#
# Uninstall Docker CE
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

TOOL_NAME="Docker CE"

echo -e "  ${BOX_ARROW} Removing ${C_WHITE}${TOOL_NAME}${C_RESET}..."

# Stop Docker service if running
sudo systemctl stop docker 2>/dev/null || true
sudo systemctl stop containerd 2>/dev/null || true

# Remove Docker packages
sudo apt-get remove -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
sudo apt-get autoremove -y 2>/dev/null || true

# Remove data directories
sudo rm -rf /var/lib/docker /var/lib/containerd

# Remove Docker repository and GPG key
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/docker.gpg

# Remove WSL Docker start helper
rm -f "${HOME}/.local/bin/docker-wsl-start"

# Clean up shell RC references
for rc_file in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
    if [ -f "${rc_file}" ]; then
        sed -i '/# Auto-start Docker in WSL/d' "${rc_file}" 2>/dev/null || true
        sed -i '/docker-wsl-start/d' "${rc_file}" 2>/dev/null || true
    fi
done

sudo apt-get update -qq 2>/dev/null || true

if ! command_exists docker; then
    echo -e "  ${BOX_CHECK} ${C_GREEN}${TOOL_NAME} removed${C_RESET}"
else
    echo -e "  ${BOX_WARN} ${C_YELLOW}${TOOL_NAME} may not be fully removed${C_RESET}"
fi
