#!/usr/bin/env bash
#
# Bicep CLI Installation
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Bicep"

if command_exists bicep; then
    version=$(bicep --version 2>/dev/null | awk '{print $4}')
    show_installed "Bicep ($version)"
    exit 0
fi

# Install Bicep CLI - download binary directly for non-interactive install
ARCH=$(uname -m)
case $ARCH in
    x86_64) BICEP_ARCH="linux-x64" ;;
    aarch64) BICEP_ARCH="linux-arm64" ;;
esac

mkdir -p "$HOME/.azure/bin"
curl -sL "https://github.com/Azure/bicep/releases/latest/download/bicep-${BICEP_ARCH}" -o "$HOME/.azure/bin/bicep" 2>/dev/null
chmod +x "$HOME/.azure/bin/bicep" 2>/dev/null

# Add to PATH
if [ -d "$HOME/.azure/bin" ]; then
    export PATH="$HOME/.azure/bin:$PATH"
    SHELL_RC="$HOME/.bashrc"
    [ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.zshrc"
    if ! grep -q ".azure/bin" "$SHELL_RC" 2>/dev/null; then
        echo 'export PATH="$HOME/.azure/bin:$PATH"' >> "$SHELL_RC"
    fi
fi

if command_exists bicep || [ -x "$HOME/.azure/bin/bicep" ]; then
    version=$(bicep --version 2>/dev/null | awk '{print $4}' || echo "installed")
    show_installed "Bicep ($version)"
else
    show_warn "Bicep installation failed"
fi
