#!/usr/bin/env bash
# fzf - fuzzy finder
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "fzf"

if command_exists fzf; then
    version=$(fzf --version 2>/dev/null | awk '{print $1}')
    show_installed "fzf ($version)"
    exit 0
fi

# Install fzf
rm -rf "$HOME/.fzf" 2>/dev/null
git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" 2>/dev/null
yes | "$HOME/.fzf/install" --all --no-bash --no-fish >/dev/null 2>&1 || true

# Ensure fzf is in PATH for current session
export PATH="$HOME/.fzf/bin:$PATH"

if command_exists fzf; then
    version=$(fzf --version 2>/dev/null | awk '{print $1}')
    show_installed "fzf ($version)"
else
    show_warn "fzf installation failed"
fi
