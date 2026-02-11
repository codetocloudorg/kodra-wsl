#!/usr/bin/env bash
# lazygit - terminal UI for git
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "lazygit"

if command_exists lazygit; then
    version=$(lazygit --version 2>/dev/null | head -1 | awk -F',' '{print $1}' | awk '{print $NF}')
    show_installed "lazygit ($version)"
    exit 0
fi

LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r '.tag_name' | tr -d 'v')
ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    amd64) ARCH="x86_64" ;;
    arm64) ARCH="arm64" ;;
esac

curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz" | \
    sudo tar xzf - -C /usr/local/bin lazygit 2>/dev/null

if command_exists lazygit; then
    version=$(lazygit --version 2>/dev/null | head -1 | awk -F',' '{print $1}' | awk '{print $NF}')
    show_installed "lazygit ($version)"
else
    show_warn "lazygit installation failed"
fi
