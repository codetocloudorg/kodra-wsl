#!/usr/bin/env bash
#
# lazydocker - Terminal UI for Docker
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "lazydocker"

if command_exists lazydocker; then
    version=$(lazydocker --version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "lazydocker ($version)"
    exit 0
fi

# Install via Go or download binary
LAZYDOCKER_VERSION="0.23.1"
ARCH=$(uname -m)

case "$ARCH" in
    x86_64) ARCH="x86_64" ;;
    aarch64) ARCH="arm64" ;;
    armv7l) ARCH="armv7" ;;
esac

# Download and install
curl -sL "https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_${ARCH}.tar.gz" | \
    sudo tar xzf - -C /usr/local/bin lazydocker 2>/dev/null

if command_exists lazydocker; then
    version=$(lazydocker --version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "lazydocker ($version)"
else
    show_warn "lazydocker installation failed"
fi
