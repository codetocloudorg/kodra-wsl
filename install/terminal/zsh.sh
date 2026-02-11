#!/usr/bin/env bash
#
# Zsh Installation and Configuration
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Zsh"

# Install Zsh if not present
if ! command_exists zsh; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq zsh >/dev/null 2>&1
fi

# Set Zsh as default shell if not already
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s "$(which zsh)" "$USER" 2>/dev/null || true
fi

# Create basic .zshrc if it doesn't exist
if [ ! -f "$HOME/.zshrc" ]; then
    cat > "$HOME/.zshrc" << 'ZSHRC'
# Kodra WSL Zsh Configuration

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Key bindings
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# Completion
autoload -Uz compinit
compinit -d ~/.zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Colors
autoload -U colors && colors

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Prompt (will be overridden by Oh My Posh)
PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f$ '

# PATH
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
ZSHRC
fi

version=$(zsh --version 2>/dev/null | awk '{print $2}')
show_installed "Zsh ($version)"
