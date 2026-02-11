#!/usr/bin/env bash
#
# Oh My Posh Installation and Configuration
# https://ohmyposh.dev/
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Oh My Posh"

# Check if already installed
if command_exists oh-my-posh; then
    version=$(oh-my-posh version 2>/dev/null)
    show_installed "Oh My Posh ($version)"
    exit 0
fi

# Install Oh My Posh via wget (user already has wget installed)
# This installs to ~/.local/bin which is in PATH
mkdir -p "$HOME/.local/bin"
wget -qO "$HOME/.local/bin/oh-my-posh" https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64
chmod +x "$HOME/.local/bin/oh-my-posh"

# Create themes directory
mkdir -p "$HOME/.config/oh-my-posh/themes"

# Download the 1_shell theme
wget -qO "$HOME/.config/oh-my-posh/themes/1_shell.omp.json" \
    https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json

# Create a custom Kodra theme based on 1_shell with Azure/K8s awareness
cat > "$HOME/.config/oh-my-posh/themes/kodra.omp.json" << 'THEME'
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "version": 2,
  "final_space": true,
  "console_title_template": "{{ .Shell }} in {{ .Folder }}",
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        {
          "type": "os",
          "style": "diamond",
          "foreground": "#ffffff",
          "background": "#0077c2",
          "leading_diamond": "\ue0b6",
          "template": " {{ if .WSL }}WSL {{ end }}\ue712 "
        },
        {
          "type": "session",
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "foreground": "#ffffff",
          "background": "#6272a4",
          "template": " {{ .UserName }}@{{ .HostName }} "
        },
        {
          "type": "path",
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "foreground": "#ffffff",
          "background": "#bd93f9",
          "properties": {
            "style": "folder"
          },
          "template": " \uf07c {{ .Path }} "
        },
        {
          "type": "git",
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "foreground": "#ffffff",
          "background": "#50fa7b",
          "background_templates": [
            "{{ if or (.Working.Changed) (.Staging.Changed) }}#ffb86c{{ end }}",
            "{{ if and (gt .Ahead 0) (gt .Behind 0) }}#ff5555{{ end }}",
            "{{ if gt .Ahead 0 }}#ff79c6{{ end }}",
            "{{ if gt .Behind 0 }}#8be9fd{{ end }}"
          ],
          "properties": {
            "branch_icon": "\ue725 ",
            "fetch_status": true,
            "fetch_upstream_icon": true
          },
          "template": " {{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} \uf044 {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }} \uf046 {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }} \ueb4b {{ .StashCount }}{{ end }} "
        },
        {
          "type": "az",
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "foreground": "#ffffff",
          "background": "#0078d4",
          "template": " \uebd8 {{ .Name }} ",
          "properties": {
            "source": "cli"
          }
        },
        {
          "type": "kubectl",
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "foreground": "#ffffff",
          "background": "#326ce5",
          "template": " \udb84\udcfe {{ .Context }}{{ if .Namespace }} :: {{ .Namespace }}{{ end }} "
        },
        {
          "type": "docker",
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "foreground": "#ffffff",
          "background": "#2496ed",
          "template": " \uf308 {{ .Context }} "
        }
      ]
    },
    {
      "type": "prompt",
      "alignment": "right",
      "segments": [
        {
          "type": "executiontime",
          "style": "plain",
          "foreground": "#f1fa8c",
          "properties": {
            "threshold": 2000
          },
          "template": " \uf252 {{ .FormattedMs }}"
        },
        {
          "type": "time",
          "style": "plain",
          "foreground": "#6272a4",
          "template": " {{ .CurrentDate | date .Format }}",
          "properties": {
            "time_format": "15:04:05"
          }
        }
      ]
    },
    {
      "type": "prompt",
      "alignment": "left",
      "newline": true,
      "segments": [
        {
          "type": "text",
          "style": "plain",
          "foreground_templates": [
            "{{if gt .Code 0}}#ff5555{{end}}",
            "{{if eq .Code 0}}#50fa7b{{end}}"
          ],
          "template": "\u276f "
        }
      ]
    }
  ],
  "transient_prompt": {
    "foreground_templates": [
      "{{if gt .Code 0}}#ff5555{{end}}",
      "{{if eq .Code 0}}#50fa7b{{end}}"
    ],
    "template": "\u276f "
  }
}
THEME

# Add Oh My Posh initialization to shell RC files
SHELL_RC="$HOME/.zshrc"
[ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.bashrc"

# Remove any existing Starship initialization
if grep -q 'eval "$(starship init' "$SHELL_RC" 2>/dev/null; then
    sed -i '/# Starship prompt/d' "$SHELL_RC"
    sed -i '/eval "$(starship init/d' "$SHELL_RC"
fi

# Add Oh My Posh initialization if not present
if ! grep -q 'oh-my-posh init' "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" << 'POSH_INIT'

# Oh My Posh prompt (1_shell theme)
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/1_shell.omp.json)"
POSH_INIT
fi

# Also configure for bash in case it's used
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q 'oh-my-posh init' "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" << 'POSH_INIT_BASH'

# Oh My Posh prompt (1_shell theme)
eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/themes/1_shell.omp.json)"
POSH_INIT_BASH
    fi
fi

if command_exists oh-my-posh || [ -x "$HOME/.local/bin/oh-my-posh" ]; then
    version=$("$HOME/.local/bin/oh-my-posh" version 2>/dev/null || oh-my-posh version 2>/dev/null)
    show_installed "Oh My Posh ($version) with 1_shell theme"
else
    show_warn "Oh My Posh installation failed"
fi
