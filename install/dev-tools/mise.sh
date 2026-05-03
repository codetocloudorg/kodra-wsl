#!/usr/bin/env bash
set -e
#
# mise — Polyglot version manager (Node, Python, Go, Rust, Java, etc.)
# https://mise.jdx.dev/
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "mise"

# Ensure ~/.local/bin exists and is in PATH
mkdir -p "${HOME}/.local/bin"
export PATH="${HOME}/.local/bin:${PATH}"

if command_exists mise; then
    version=$(mise --version 2>/dev/null | awk '{print $1}')
    show_installed "mise ($version)"
    exit 0
fi

# Install via official installer
curl -fsSL https://mise.run | sh >/dev/null 2>&1

# Activate mise in current shell
if [ -x "${HOME}/.local/bin/mise" ]; then
    eval "$("${HOME}/.local/bin/mise" activate bash)" 2>/dev/null || true
fi

# Configure shell RC files for mise activation
configure_mise_rc() {
    local rc_file="$1"
    local shell_name="$2"

    [ ! -f "${rc_file}" ] && return

    if ! grep -q 'mise activate' "${rc_file}" 2>/dev/null; then
        cat >> "${rc_file}" << MISE_INIT

# mise — polyglot version manager
eval "\$(${HOME}/.local/bin/mise activate ${shell_name})"
MISE_INIT
    fi
}

if [ -f "${HOME}/.bashrc" ]; then
    configure_mise_rc "${HOME}/.bashrc" "bash"
fi

if [ -f "${HOME}/.zshrc" ]; then
    configure_mise_rc "${HOME}/.zshrc" "zsh"
fi

# Create default config with sensible defaults
mkdir -p "${HOME}/.config/mise"
if [ ! -f "${HOME}/.config/mise/config.toml" ]; then
    cat > "${HOME}/.config/mise/config.toml" << 'MISE_CONFIG'
# mise configuration — https://mise.jdx.dev/configuration.html
# Managed by Kodra WSL

[settings]
# Automatically install tools when entering a directory with .tool-versions or mise.toml
auto_install = true
# Use verbose output for debugging (set to true if needed)
verbose = false
# Trust all config files by default in home directory
trusted_config_paths = ["~"]

[tools]
node = "lts"
python = "latest"
MISE_CONFIG
fi

# Install default tool versions
if [ -x "${HOME}/.local/bin/mise" ]; then
    "${HOME}/.local/bin/mise" install --yes >/dev/null 2>&1 || true
fi

# Verify installation
if command_exists mise || [ -x "${HOME}/.local/bin/mise" ]; then
    version=$("${HOME}/.local/bin/mise" --version 2>/dev/null | awk '{print $1}')
    show_installed "mise ($version)"
else
    show_warn "mise installation failed"
fi
