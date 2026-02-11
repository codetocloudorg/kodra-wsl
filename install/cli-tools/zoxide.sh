#!/usr/bin/env bash
# zoxide - smarter cd command
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "zoxide"

if command_exists zoxide; then
    version=$(zoxide --version 2>/dev/null | awk '{print $2}')
    show_installed "zoxide ($version)"
    exit 0
fi

curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash >/dev/null 2>&1

# Add to PATH
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if command_exists zoxide; then
    version=$(zoxide --version 2>/dev/null | awk '{print $2}')
    show_installed "zoxide ($version)"
else
    show_warn "zoxide installation failed"
fi
