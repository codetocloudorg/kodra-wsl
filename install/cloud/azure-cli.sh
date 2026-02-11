#!/usr/bin/env bash
#
# Azure CLI Installation
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Azure CLI"

if command_exists az; then
    version=$(az version --query '"azure-cli"' -o tsv 2>/dev/null)
    show_installed "Azure CLI ($version)"
    exit 0
fi

# Install Azure CLI using Microsoft's recommended method
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash >/dev/null 2>&1

if command_exists az; then
    version=$(az version --query '"azure-cli"' -o tsv 2>/dev/null)
    show_installed "Azure CLI ($version)"
else
    show_warn "Azure CLI installation failed"
fi
