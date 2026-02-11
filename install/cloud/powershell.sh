#!/usr/bin/env bash
#
# PowerShell 7 Installation
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "PowerShell 7"

if command_exists pwsh; then
    version=$(pwsh --version 2>/dev/null | awk '{print $2}')
    show_installed "PowerShell ($version)"
    exit 0
fi

# Install PowerShell from Microsoft repository
sudo apt-get update -qq
sudo apt-get install -y -qq wget apt-transport-https software-properties-common >/dev/null 2>&1

# Download and install Microsoft repository GPG keys
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" -O /tmp/packages-microsoft-prod.deb
sudo dpkg -i /tmp/packages-microsoft-prod.deb >/dev/null 2>&1
rm -f /tmp/packages-microsoft-prod.deb

# Install PowerShell
sudo apt-get update -qq
sudo apt-get install -y -qq powershell >/dev/null 2>&1

if command_exists pwsh; then
    version=$(pwsh --version 2>/dev/null | awk '{print $2}')
    show_installed "PowerShell ($version)"
else
    show_warn "PowerShell installation failed"
fi
