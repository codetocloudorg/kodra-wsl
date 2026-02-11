#!/usr/bin/env bash
#
# Helm Installation
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Helm"

if command_exists helm; then
    version=$(helm version --short 2>/dev/null | awk -F'+' '{print $1}')
    show_installed "Helm ($version)"
    exit 0
fi

# Install Helm using official script
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash >/dev/null 2>&1

if command_exists helm; then
    version=$(helm version --short 2>/dev/null | awk -F'+' '{print $1}')
    show_installed "Helm ($version)"
else
    show_warn "Helm installation failed"
fi
