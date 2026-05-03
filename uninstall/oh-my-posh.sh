#!/usr/bin/env bash
set -e
#
# Uninstall Oh My Posh
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

TOOL_NAME="Oh My Posh"

echo -e "  ${BOX_ARROW} Removing ${C_WHITE}${TOOL_NAME}${C_RESET}..."

# Remove binary
sudo rm -f /usr/local/bin/oh-my-posh
rm -f "${HOME}/.local/bin/oh-my-posh"

# Remove cache and config
rm -rf "${HOME}/.cache/oh-my-posh"
rm -rf "${HOME}/.config/oh-my-posh"

# Clean up shell RC references
for rc_file in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
    if [ -f "${rc_file}" ]; then
        sed -i '/# Oh My Posh prompt/d' "${rc_file}" 2>/dev/null || true
        sed -i '/oh-my-posh init/d' "${rc_file}" 2>/dev/null || true
        sed -i '/# Change theme: oh-my-posh/d' "${rc_file}" 2>/dev/null || true
    fi
done

if ! command_exists oh-my-posh && [ ! -x "${HOME}/.local/bin/oh-my-posh" ]; then
    echo -e "  ${BOX_CHECK} ${C_GREEN}${TOOL_NAME} removed${C_RESET}"
else
    echo -e "  ${BOX_WARN} ${C_YELLOW}${TOOL_NAME} may not be fully removed${C_RESET}"
fi
