#!/usr/bin/env bash
# eza - modern ls replacement
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "eza"

if command_exists eza; then
    version=$(eza --version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "eza ($version)"
    exit 0
fi

# Install eza from GitHub releases
EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | jq -r '.tag_name' | tr -d 'v')
ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH="x86_64" ;;
    aarch64) ARCH="aarch64" ;;
esac

# Try binary download first
wget -qO /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_${ARCH}-unknown-linux-gnu.tar.gz" 2>/dev/null
if [ -f /tmp/eza.tar.gz ] && [ -s /tmp/eza.tar.gz ]; then
    tar xzf /tmp/eza.tar.gz -C /tmp 2>/dev/null
    sudo cp /tmp/eza /usr/local/bin/ 2>/dev/null
    rm -f /tmp/eza.tar.gz /tmp/eza
fi

# Fallback: install via cargo if available
if ! command_exists eza && command_exists cargo; then
    cargo install eza --locked 2>/dev/null
fi

if command_exists eza; then
    version=$(eza --version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "eza ($version)"
else
    show_warn "eza installation failed"
fi
