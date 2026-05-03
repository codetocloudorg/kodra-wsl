#!/usr/bin/env bash
set -e
#
# Migration: 0.7.1 → 0.8.0
# Feature parity update: shell configs, new CLI commands, mise version manager
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

MIGRATION_ID="20260503-0.7.1-to-0.8.0"
MIGRATION_DESC="Feature parity update: shell configs, new CLI commands"
MIGRATION_STATE_DIR="${HOME}/.config/kodra/migrations"

# Check if migration has already been applied
is_applied() {
    [ -f "${MIGRATION_STATE_DIR}/${MIGRATION_ID}.done" ]
}

migrate_up() {
    echo -e "  ${BOX_ARROW} Applying migration: ${C_WHITE}${MIGRATION_DESC}${C_RESET}"

    # Create config directories
    mkdir -p "${HOME}/.config/kodra/shell"
    mkdir -p "${MIGRATION_STATE_DIR}"

    # Copy new shell config files if they exist in the Kodra distribution
    if [ -d "${KODRA_DIR}/configs/shell" ]; then
        cp -r "${KODRA_DIR}/configs/shell/." "${HOME}/.config/kodra/shell/" 2>/dev/null || true
    fi

    # Source new aliases from bashrc
    if [ -f "${HOME}/.config/kodra/shell/aliases.sh" ]; then
        if ! grep -q "kodra/shell/aliases.sh" "${HOME}/.bashrc" 2>/dev/null; then
            cat >> "${HOME}/.bashrc" << 'ALIASES'

# Kodra shell aliases
[ -f ~/.config/kodra/shell/aliases.sh ] && source ~/.config/kodra/shell/aliases.sh
ALIASES
        fi

        # Also add to zshrc if it exists
        if [ -f "${HOME}/.zshrc" ]; then
            if ! grep -q "kodra/shell/aliases.sh" "${HOME}/.zshrc" 2>/dev/null; then
                cat >> "${HOME}/.zshrc" << 'ALIASES'

# Kodra shell aliases
[ -f ~/.config/kodra/shell/aliases.sh ] && source ~/.config/kodra/shell/aliases.sh
ALIASES
            fi
        fi
    fi

    # Install completions for kodra CLI
    if [ -f "${KODRA_DIR}/completions/kodra.bash" ]; then
        mkdir -p "${HOME}/.local/share/bash-completion/completions"
        cp "${KODRA_DIR}/completions/kodra.bash" \
            "${HOME}/.local/share/bash-completion/completions/kodra" 2>/dev/null || true
    fi

    # Install mise if not present (new in 0.8.0)
    if ! command_exists mise && [ ! -x "${HOME}/.local/bin/mise" ]; then
        if [ -f "${KODRA_DIR}/install/dev-tools/mise.sh" ]; then
            bash "${KODRA_DIR}/install/dev-tools/mise.sh" 2>/dev/null || true
        fi
    fi

    # Mark migration as applied
    date -u +"%Y-%m-%dT%H:%M:%SZ" > "${MIGRATION_STATE_DIR}/${MIGRATION_ID}.done"
    echo -e "  ${BOX_CHECK} ${C_GREEN}Migration ${MIGRATION_ID} applied${C_RESET}"
}

migrate_down() {
    echo -e "  ${BOX_ARROW} Rolling back migration: ${C_WHITE}${MIGRATION_DESC}${C_RESET}"

    # Remove aliases sourcing from shell RCs
    for rc_file in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
        if [ -f "${rc_file}" ]; then
            sed -i '/# Kodra shell aliases/d' "${rc_file}" 2>/dev/null || true
            sed -i '/kodra\/shell\/aliases.sh/d' "${rc_file}" 2>/dev/null || true
        fi
    done

    # Remove completions
    rm -f "${HOME}/.local/share/bash-completion/completions/kodra"

    # Remove shell config directory
    rm -rf "${HOME}/.config/kodra/shell"

    # Remove migration state
    rm -f "${MIGRATION_STATE_DIR}/${MIGRATION_ID}.done"
    echo -e "  ${BOX_CHECK} ${C_GREEN}Migration ${MIGRATION_ID} rolled back${C_RESET}"
}

# Entry point — run based on argument
case "${1:-up}" in
    up)
        if is_applied; then
            echo -e "  ${BOX_DOT} ${C_GRAY}Migration ${MIGRATION_ID} already applied${C_RESET}"
            exit 0
        fi
        migrate_up
        ;;
    down)
        if ! is_applied; then
            echo -e "  ${BOX_DOT} ${C_GRAY}Migration ${MIGRATION_ID} not applied, nothing to roll back${C_RESET}"
            exit 0
        fi
        migrate_down
        ;;
    status)
        if is_applied; then
            echo "applied"
        else
            echo "pending"
        fi
        ;;
    *)
        echo "Usage: $0 {up|down|status}"
        exit 1
        ;;
esac
