#!/usr/bin/env bash
#
# Kodra WSL Config Management
#
# Shell-based key=value settings in ~/.config/kodra/settings
#

KODRA_SETTINGS_FILE="${HOME}/.config/kodra/settings"

# Default values
declare -A _KODRA_DEFAULTS=(
    [motd_style]="banner"
    [auto_update]="true"
    [shell]="bash"
    [theme]="default"
)

# Get a config value (returns default if unset)
get_config() {
    local key="$1"
    local default="${_KODRA_DEFAULTS[${key}]:-}"

    if [ -f "${KODRA_SETTINGS_FILE}" ]; then
        local value
        value="$(grep -E "^${key}=" "${KODRA_SETTINGS_FILE}" 2>/dev/null | head -1 | cut -d= -f2-)"
        if [ -n "${value}" ]; then
            echo "${value}"
            return
        fi
    fi

    echo "${default}"
}

# Set a config value
set_config() {
    local key="$1"
    local value="$2"
    local settings_dir
    settings_dir="$(dirname "${KODRA_SETTINGS_FILE}")"

    mkdir -p "${settings_dir}"

    if [ -f "${KODRA_SETTINGS_FILE}" ] && grep -qE "^${key}=" "${KODRA_SETTINGS_FILE}" 2>/dev/null; then
        # Update existing key
        sed -i "s|^${key}=.*|${key}=${value}|" "${KODRA_SETTINGS_FILE}"
    else
        # Append new key
        echo "${key}=${value}" >> "${KODRA_SETTINGS_FILE}"
    fi
}

# Reset config to defaults
reset_config() {
    local settings_dir
    settings_dir="$(dirname "${KODRA_SETTINGS_FILE}")"
    mkdir -p "${settings_dir}"

    cat > "${KODRA_SETTINGS_FILE}" << EOF
# Kodra WSL Settings
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
motd_style=banner
auto_update=true
shell=bash
theme=default
EOF

    echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} Config reset to defaults"
}
