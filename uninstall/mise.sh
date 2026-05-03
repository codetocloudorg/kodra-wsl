#!/usr/bin/env bash
set -e
#
# Uninstall mise
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

TOOL_NAME="mise"

echo -e "  ${BOX_ARROW} Removing ${C_WHITE}${TOOL_NAME}${C_RESET}..."

# Remove binary, data, and config
rm -rf "${HOME}/.local/bin/mise"
rm -rf "${HOME}/.local/share/mise"
rm -rf "${HOME}/.config/mise"

# Clean up shell RC references
for rc_file in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
    if [ -f "${rc_file}" ]; then
        sed -i '/# mise/d' "${rc_file}" 2>/dev/null || true
        sed -i '/mise activate/d' "${rc_file}" 2>/dev/null || true
    fi
done

if ! command_exists mise && [ ! -x "${HOME}/.local/bin/mise" ]; then
    echo -e "  ${BOX_CHECK} ${C_GREEN}${TOOL_NAME} removed${C_RESET}"
else
    echo -e "  ${BOX_WARN} ${C_YELLOW}${TOOL_NAME} may not be fully removed${C_RESET}"
fi
