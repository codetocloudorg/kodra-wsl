#!/usr/bin/env bash
#
# k9s Installation - Kubernetes TUI
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "k9s"

if command_exists k9s; then
    version=$(k9s version --short 2>/dev/null | head -1)
    show_installed "k9s ($version)"
    exit 0
fi

# Get latest version
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    amd64) ARCH="amd64" ;;
    arm64) ARCH="arm64" ;;
esac

# Download and install
curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz" | \
    sudo tar xzf - -C /usr/local/bin k9s 2>/dev/null

if command_exists k9s; then
    version=$(k9s version --short 2>/dev/null | head -1 || echo "installed")
    show_installed "k9s ($version)"
else
    show_warn "k9s installation failed"
fi
