#!/usr/bin/env bash
#
# Starship Prompt Installation
#
# DEPRECATED: Oh My Posh is now the default prompt in Kodra WSL.
# This script is kept for users who prefer Starship.
# To use Starship instead of Oh My Posh, run this script manually.
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Starship prompt (alternative to Oh My Posh)"

if command_exists starship; then
    version=$(starship --version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "Starship ($version)"
    exit 0
fi

# Install Starship (requires sudo for /usr/local/bin)
curl -sS https://starship.rs/install.sh | sudo sh -s -- -y >/dev/null 2>&1

# Create Starship config
mkdir -p "$HOME/.config"
cat > "$HOME/.config/starship.toml" << 'STARSHIP'
# Kodra WSL Starship Configuration

format = """
$username$hostname$directory$git_branch$git_status$azure$kubernetes$docker_context$cmd_duration$line_break$character"""

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"

[username]
style_user = "cyan bold"
style_root = "red bold"
format = "[$user]($style)"
show_always = false

[hostname]
ssh_only = true
format = "[@$hostname](bold blue) "

[directory]
style = "blue bold"
truncation_length = 3
truncate_to_repo = true
format = " [$path]($style)[$read_only]($read_only_style) "

[git_branch]
symbol = " "
style = "purple"
format = "[$symbol$branch]($style)"

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "red"

[azure]
disabled = false
format = "[$symbol($subscription)]($style) "
symbol = "󰠅 "
style = "blue"

[kubernetes]
disabled = false
format = '[$symbol$context( \($namespace\))]($style) '
symbol = "󱃾 "
style = "cyan"

[docker_context]
symbol = " "
style = "blue"
format = "[$symbol$context]($style) "
only_with_files = true

[cmd_duration]
min_time = 2000
format = "[$duration]($style) "
style = "yellow"

[aws]
disabled = true

[gcloud]
disabled = true
STARSHIP

# Add to shell RC
SHELL_RC="$HOME/.zshrc"
[ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.bashrc"

if ! grep -q 'eval "$(starship init' "$SHELL_RC" 2>/dev/null; then
    echo '' >> "$SHELL_RC"
    echo '# Starship prompt' >> "$SHELL_RC"
    echo 'eval "$(starship init zsh)"' >> "$SHELL_RC"
fi

if command_exists starship; then
    version=$(starship --version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "Starship ($version)"
else
    show_warn "Starship installation failed"
fi
