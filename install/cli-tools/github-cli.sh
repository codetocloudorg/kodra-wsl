#!/usr/bin/env bash
# GitHub CLI
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "GitHub CLI"

if command_exists gh; then
    version=$(gh --version 2>/dev/null | head -1 | awk '{print $3}')
    show_installed "GitHub CLI ($version)"
    exit 0
fi

# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

sudo apt-get update -qq
sudo apt-get install -y -qq gh >/dev/null 2>&1

if command_exists gh; then
    version=$(gh --version 2>/dev/null | head -1 | awk '{print $3}')
    show_installed "GitHub CLI ($version)"
else
    show_warn "GitHub CLI installation failed"
fi
