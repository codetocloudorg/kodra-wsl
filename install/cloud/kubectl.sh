#!/usr/bin/env bash
#
# kubectl Installation
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "kubectl"

if command_exists kubectl; then
    version=$(kubectl version --client -o json 2>/dev/null | jq -r '.clientVersion.gitVersion' || echo "installed")
    show_installed "kubectl ($version)"
    exit 0
fi

# Install kubectl from Kubernetes repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg 2>/dev/null
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

sudo apt-get update -qq
sudo apt-get install -y -qq kubectl >/dev/null 2>&1

if command_exists kubectl; then
    version=$(kubectl version --client -o json 2>/dev/null | jq -r '.clientVersion.gitVersion' || echo "installed")
    show_installed "kubectl ($version)"
else
    show_warn "kubectl installation failed"
fi
