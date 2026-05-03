#!/usr/bin/env bash
#
# Kodra WSL Config Backup / Restore
#
# Back up and restore dotfiles, shell configs, and tool configs.
# No dconf (GNOME-only). WSL-appropriate only.
#

KODRA_BACKUP_DIR="${HOME}/.config/kodra/backups"

# Dotfiles to back up
_KODRA_DOTFILES=(
    "${HOME}/.bashrc"
    "${HOME}/.profile"
    "${HOME}/.bash_profile"
    "${HOME}/.bash_aliases"
    "${HOME}/.zshrc"
    "${HOME}/.zprofile"
)

# Shell config paths
_KODRA_SHELL_CONFIGS=(
    "${HOME}/.bashrc"
    "${HOME}/.profile"
    "${HOME}/.bash_profile"
    "${HOME}/.zshrc"
)

# Tool config paths
_KODRA_TOOL_CONFIGS=(
    "${HOME}/.config/ohmyposh"
    "${HOME}/.poshthemes"
    "${HOME}/.config/btop"
    "${HOME}/.config/fastfetch"
    "${HOME}/.gitconfig"
    "${HOME}/.config/kodra"
    "${HOME}/.config/lazygit"
    "${HOME}/.config/bat"
)

# Create a timestamped backup
create_backup() {
    local label="${1:-manual}"
    local timestamp
    timestamp="$(date +%Y%m%d-%H%M%S)"
    local backup_path="${KODRA_BACKUP_DIR}/${timestamp}-${label}"

    mkdir -p "${backup_path}"

    backup_dotfiles "${backup_path}"
    backup_shell_config "${backup_path}"
    backup_tool_configs "${backup_path}"

    # Write metadata
    cat > "${backup_path}/metadata.json" << EOF
{
  "label": "${label}",
  "timestamp": "${timestamp}",
  "date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "hostname": "$(hostname)",
  "user": "${USER}"
}
EOF

    echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} Backup created: ${backup_path}"
}

# Restore from a backup
restore_backup() {
    local backup_path="$1"

    if [ ! -d "${backup_path}" ]; then
        echo -e "    ${C_RED}${BOX_CROSS}${C_RESET} Backup not found: ${backup_path}"
        return 1
    fi

    restore_dotfiles "${backup_path}"
    restore_shell_config "${backup_path}"
    restore_tool_configs "${backup_path}"

    echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} Restore complete from: ${backup_path}"
}

# List available backups
list_backups() {
    if [ ! -d "${KODRA_BACKUP_DIR}" ]; then
        echo -e "    ${C_YELLOW}${BOX_WARN}${C_RESET} No backups found"
        return
    fi

    local count=0
    for entry in "${KODRA_BACKUP_DIR}"/*/; do
        [ -d "${entry}" ] || continue
        local name
        name="$(basename "${entry}")"
        local size
        size="$(du -sh "${entry}" 2>/dev/null | cut -f1)"
        echo -e "    ${C_CYAN}${BOX_DOT}${C_RESET} ${name}  ${C_DIM}(${size})${C_RESET}"
        count=$((count + 1))
    done

    if [ "${count}" -eq 0 ]; then
        echo -e "    ${C_YELLOW}${BOX_WARN}${C_RESET} No backups found"
    fi
}

# Delete a specific backup
delete_backup() {
    local backup_path="$1"

    if [ ! -d "${backup_path}" ]; then
        echo -e "    ${C_RED}${BOX_CROSS}${C_RESET} Backup not found: ${backup_path}"
        return 1
    fi

    rm -rf "${backup_path}"
    echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} Deleted: ${backup_path}"
}

# Back up dotfiles
backup_dotfiles() {
    local dest="$1"
    local dotfiles_dir="${dest}/dotfiles"
    mkdir -p "${dotfiles_dir}"

    for file in "${_KODRA_DOTFILES[@]}"; do
        if [ -f "${file}" ]; then
            cp -a "${file}" "${dotfiles_dir}/"
        fi
    done
}

# Back up shell config
backup_shell_config() {
    local dest="$1"
    local shell_dir="${dest}/shell"
    mkdir -p "${shell_dir}"

    for file in "${_KODRA_SHELL_CONFIGS[@]}"; do
        if [ -f "${file}" ]; then
            cp -a "${file}" "${shell_dir}/"
        fi
    done
}

# Back up tool configs
backup_tool_configs() {
    local dest="$1"
    local tools_dir="${dest}/tools"
    mkdir -p "${tools_dir}"

    for path in "${_KODRA_TOOL_CONFIGS[@]}"; do
        if [ -e "${path}" ]; then
            local basename
            basename="$(basename "${path}")"
            if [ -d "${path}" ]; then
                cp -a "${path}" "${tools_dir}/${basename}"
            else
                cp -a "${path}" "${tools_dir}/"
            fi
        fi
    done
}

# Restore dotfiles
restore_dotfiles() {
    local src="$1"
    local dotfiles_dir="${src}/dotfiles"

    if [ ! -d "${dotfiles_dir}" ]; then
        return
    fi

    for file in "${dotfiles_dir}"/*; do
        [ -f "${file}" ] || continue
        local basename
        basename="$(basename "${file}")"
        cp -a "${file}" "${HOME}/${basename}"
    done
}

# Restore shell config
restore_shell_config() {
    local src="$1"
    local shell_dir="${src}/shell"

    if [ ! -d "${shell_dir}" ]; then
        return
    fi

    for file in "${shell_dir}"/*; do
        [ -f "${file}" ] || continue
        local basename
        basename="$(basename "${file}")"
        cp -a "${file}" "${HOME}/${basename}"
    done
}

# Restore tool configs
restore_tool_configs() {
    local src="$1"
    local tools_dir="${src}/tools"

    if [ ! -d "${tools_dir}" ]; then
        return
    fi

    for entry in "${tools_dir}"/*; do
        [ -e "${entry}" ] || continue
        local basename
        basename="$(basename "${entry}")"

        # Determine original location
        local target=""
        case "${basename}" in
            .gitconfig)    target="${HOME}/.gitconfig" ;;
            ohmyposh)      target="${HOME}/.config/ohmyposh" ;;
            .poshthemes)   target="${HOME}/.poshthemes" ;;
            btop)          target="${HOME}/.config/btop" ;;
            fastfetch)     target="${HOME}/.config/fastfetch" ;;
            kodra)         target="${HOME}/.config/kodra" ;;
            lazygit)       target="${HOME}/.config/lazygit" ;;
            bat)           target="${HOME}/.config/bat" ;;
            *)             target="${HOME}/.config/${basename}" ;;
        esac

        if [ -d "${entry}" ]; then
            mkdir -p "$(dirname "${target}")"
            cp -a "${entry}" "${target}"
        else
            mkdir -p "$(dirname "${target}")"
            cp -a "${entry}" "${target}"
        fi
    done
}

# Get total backup size
get_backup_size() {
    if [ ! -d "${KODRA_BACKUP_DIR}" ]; then
        echo "0B"
        return
    fi

    du -sh "${KODRA_BACKUP_DIR}" 2>/dev/null | cut -f1
}

# Verify backup integrity (check metadata and that files exist)
verify_backup() {
    local backup_path="$1"

    if [ ! -d "${backup_path}" ]; then
        echo -e "    ${C_RED}${BOX_CROSS}${C_RESET} Backup directory missing"
        return 1
    fi

    if [ ! -f "${backup_path}/metadata.json" ]; then
        echo -e "    ${C_RED}${BOX_CROSS}${C_RESET} Metadata missing"
        return 1
    fi

    local file_count
    file_count="$(find "${backup_path}" -type f | wc -l)"
    if [ "${file_count}" -le 1 ]; then
        echo -e "    ${C_YELLOW}${BOX_WARN}${C_RESET} Backup contains no config files"
        return 1
    fi

    echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} Backup valid (${file_count} files)"
    return 0
}
