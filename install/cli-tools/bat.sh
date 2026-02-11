#!/usr/bin/env bash
# bat - cat with syntax highlighting
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "bat"

if command_exists bat; then
    version=$(bat --version 2>/dev/null | awk '{print $2}')
    show_installed "bat ($version)"
    exit 0
fi

sudo apt-get install -y -qq bat >/dev/null 2>&1

# On Ubuntu, bat is installed as 'batcat', create symlink
if command_exists batcat && ! command_exists bat; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    export PATH="$HOME/.local/bin:$PATH"
fi

if command_exists bat || command_exists batcat; then
    version=$(bat --version 2>/dev/null || batcat --version 2>/dev/null | awk '{print $2}')
    show_installed "bat ($version)"
else
    show_warn "bat installation failed"
fi
