#!/usr/bin/env bash
#
# Oh My Posh Installation and Shell Configuration
# https://ohmyposh.dev/
#
# Configures your shell prompt with the 1_shell theme
# Works with bash (default) or zsh if installed
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Oh My Posh"

# Ensure ~/.local/bin exists and is in PATH
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# Check if already installed and up to date
if command_exists oh-my-posh; then
    version=$(oh-my-posh version 2>/dev/null)
    show_installed "Oh My Posh ($version)"
else
    # Install Oh My Posh using official installer
    # This is the recommended method per https://ohmyposh.dev/docs/installation/linux
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin" >/dev/null 2>&1
    
    # Verify installation
    if [ ! -x "$HOME/.local/bin/oh-my-posh" ]; then
        # Fallback: direct download
        wget -qO "$HOME/.local/bin/oh-my-posh" \
            "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64"
        chmod +x "$HOME/.local/bin/oh-my-posh"
    fi
fi

# Create themes directory
mkdir -p "$HOME/.config/oh-my-posh/themes"

# Download the 1_shell theme (the one user requested)
if [ ! -f "$HOME/.config/oh-my-posh/themes/1_shell.omp.json" ]; then
    wget -qO "$HOME/.config/oh-my-posh/themes/1_shell.omp.json" \
        "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json" 2>/dev/null || true
fi

# Create a custom Kodra theme with Azure/K8s/Docker context awareness
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

# Theme to use (1_shell as requested)
OMP_THEME="$HOME/.config/oh-my-posh/themes/1_shell.omp.json"

# Function to add Oh My Posh init to a shell RC file
configure_shell_rc() {
    local rc_file="$1"
    local shell_name="$2"
    
    [ ! -f "$rc_file" ] && return
    
    # Remove any existing Starship initialization (we're replacing it)
    if grep -q 'starship init' "$rc_file" 2>/dev/null; then
        sed -i '/# Starship prompt/d' "$rc_file"
        sed -i '/eval "$(starship init/d' "$rc_file"
    fi
    
    # Remove old zoxide init (may have wrong shell syntax)
    if grep -q 'zoxide init' "$rc_file" 2>/dev/null; then
        sed -i '/# Zoxide/d' "$rc_file"
        sed -i '/zoxide init/d' "$rc_file"
    fi
    
    # Remove old Oh My Posh init if present (to update it)
    if grep -q 'oh-my-posh init' "$rc_file" 2>/dev/null; then
        sed -i '/# Oh My Posh prompt/d' "$rc_file"
        sed -i '/oh-my-posh init/d' "$rc_file"
    fi
    
    # Ensure PATH includes ~/.local/bin
    if ! grep -q 'PATH.*\.local/bin' "$rc_file" 2>/dev/null; then
        echo '' >> "$rc_file"
        echo '# Add local bin to PATH' >> "$rc_file"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc_file"
    fi
    
    # Add zoxide with correct shell syntax
    if command -v zoxide &> /dev/null && ! grep -q 'zoxide init' "$rc_file" 2>/dev/null; then
        echo '' >> "$rc_file"
        echo "# Zoxide (smart cd)" >> "$rc_file"
        echo "eval \"\$(zoxide init $shell_name)\"" >> "$rc_file"
    fi
    
    # Add Oh My Posh initialization
    cat >> "$rc_file" << POSH_INIT

# Oh My Posh prompt (1_shell theme)
# Change theme: oh-my-posh init $shell_name --config ~/.config/oh-my-posh/themes/THEME.omp.json
eval "\$(oh-my-posh init $shell_name --config $OMP_THEME)"
POSH_INIT
}

# Configure .bashrc (always - it's the default shell on Ubuntu)
if [ -f "$HOME/.bashrc" ]; then
    configure_shell_rc "$HOME/.bashrc" "bash"
fi

# Configure .zshrc if it exists (for zsh users)
if [ -f "$HOME/.zshrc" ]; then
    configure_shell_rc "$HOME/.zshrc" "zsh"
fi

# Verify installation
if command_exists oh-my-posh || [ -x "$HOME/.local/bin/oh-my-posh" ]; then
    version=$("$HOME/.local/bin/oh-my-posh" version 2>/dev/null || oh-my-posh version 2>/dev/null)
    show_installed "Oh My Posh ($version) with 1_shell theme"
else
    show_warn "Oh My Posh installation may have issues"
fi
