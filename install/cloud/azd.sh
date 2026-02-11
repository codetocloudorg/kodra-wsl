#!/usr/bin/env bash
#
# Azure Developer CLI (azd) Installation
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Azure Developer CLI (azd)"

if command_exists azd; then
    version=$(azd version 2>/dev/null | head -1)
    show_installed "azd ($version)"
    exit 0
fi

# Install azd using Microsoft's script
curl -fsSL https://aka.ms/install-azd.sh | bash -s -- -a $(dpkg --print-architecture) >/dev/null 2>&1

# Add to PATH if installed to user directory
if [ -d "$HOME/.azd/bin" ]; then
    export PATH="$HOME/.azd/bin:$PATH"
    
    # Add to shell RC
    SHELL_RC="$HOME/.zshrc"
    [ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.bashrc"
    
    if ! grep -q ".azd/bin" "$SHELL_RC" 2>/dev/null; then
        echo 'export PATH="$HOME/.azd/bin:$PATH"' >> "$SHELL_RC"
    fi
fi

if command_exists azd || [ -x "$HOME/.azd/bin/azd" ]; then
    version=$("$HOME/.azd/bin/azd" version 2>/dev/null || azd version 2>/dev/null | head -1)
    show_installed "azd ($version)"
else
    show_warn "azd installation failed"
fi
