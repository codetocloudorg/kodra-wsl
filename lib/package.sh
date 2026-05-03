#!/usr/bin/env bash
#
# Kodra WSL APT Package Helpers
#
# apt-only. No flatpak, no snap, no homebrew.
#

# Install one or more packages via apt
pkg_install() {
    local packages=("$@")
    if [ ${#packages[@]} -eq 0 ]; then
        return 1
    fi
    sudo apt-get install -y -qq "${packages[@]}" 2>&1
}

# Remove one or more packages via apt
pkg_remove() {
    local packages=("$@")
    if [ ${#packages[@]} -eq 0 ]; then
        return 1
    fi
    sudo apt-get remove -y -qq "${packages[@]}" 2>&1
}

# Check if a package is installed (return 0 if yes)
pkg_is_installed() {
    local package="$1"
    dpkg -s "${package}" &>/dev/null
}

# Update apt package index
pkg_update() {
    sudo apt-get update -qq 2>&1
}

# Upgrade installed packages
pkg_upgrade() {
    sudo apt-get upgrade -y -qq 2>&1
}

# Add an APT repository
pkg_add_repo() {
    local repo="$1"
    if command -v add-apt-repository &>/dev/null; then
        sudo add-apt-repository -y "${repo}" 2>&1
    else
        echo "${repo}" | sudo tee /etc/apt/sources.list.d/"$(echo "${repo}" | md5sum | cut -c1-8)".list > /dev/null
    fi
}

# Add a GPG key for a repository
pkg_add_key() {
    local key_url="$1"
    local keyring="${2:-/etc/apt/keyrings/kodra-added.gpg}"

    sudo mkdir -p "$(dirname "${keyring}")"

    if [[ "${key_url}" == *.asc ]] || [[ "${key_url}" == *armor* ]]; then
        curl -fsSL "${key_url}" | sudo gpg --dearmor -o "${keyring}" 2>/dev/null
    else
        curl -fsSL "${key_url}" | sudo tee "${keyring}" > /dev/null
    fi
}

# Clean apt cache
pkg_clean() {
    sudo apt-get clean -qq 2>&1
}

# Remove unused packages
pkg_autoremove() {
    sudo apt-get autoremove -y -qq 2>&1
}

# List installed packages (one per line)
pkg_list_installed() {
    dpkg --get-selections | grep -v deinstall | awk '{print $1}'
}

# Search for packages matching a pattern
pkg_search() {
    local pattern="$1"
    apt-cache search "${pattern}" 2>/dev/null
}

# Install a binary from a GitHub release
install_from_github_release() {
    local owner="$1"
    local repo="$2"
    local asset_pattern="$3"
    local dest="${4:-/usr/local/bin}"

    local tag
    tag="$(get_latest_github_release "${owner}" "${repo}")"
    if [ -z "${tag}" ]; then
        echo -e "    ${C_RED}${BOX_CROSS}${C_RESET} Could not get latest release for ${owner}/${repo}"
        return 1
    fi

    local download_url="https://github.com/${owner}/${repo}/releases/download/${tag}/${asset_pattern}"

    local workdir="${HOME}/.cache/kodra/downloads"
    mkdir -p "${workdir}"

    local filename
    filename="$(basename "${asset_pattern}")"
    curl -fsSL -o "${workdir}/${filename}" "${download_url}" || return 1

    case "${filename}" in
        *.tar.gz|*.tgz)
            tar -xzf "${workdir}/${filename}" -C "${workdir}"
            ;;
        *.deb)
            sudo dpkg -i "${workdir}/${filename}" 2>&1
            rm -f "${workdir}/${filename}"
            return
            ;;
        *.zip)
            unzip -oq "${workdir}/${filename}" -d "${workdir}"
            ;;
        *)
            chmod +x "${workdir}/${filename}"
            sudo mv "${workdir}/${filename}" "${dest}/"
            return
            ;;
    esac

    # Move extracted binaries to dest
    find "${workdir}" -maxdepth 2 -type f -executable ! -name '*.tar.gz' ! -name '*.zip' | while read -r bin; do
        sudo mv "${bin}" "${dest}/"
    done

    rm -rf "${workdir:?}/"*
}

# Install a .deb from a URL
install_deb_from_url() {
    local url="$1"

    local workdir="${HOME}/.cache/kodra/downloads"
    mkdir -p "${workdir}"

    local filename
    filename="$(basename "${url}")"
    curl -fsSL -o "${workdir}/${filename}" "${url}" || return 1
    sudo dpkg -i "${workdir}/${filename}" 2>&1 || sudo apt-get install -f -y -qq 2>&1
    rm -f "${workdir}/${filename}"
}

# Get the latest release tag from GitHub API
get_latest_github_release() {
    local owner="$1"
    local repo="$2"

    local tag
    tag="$(curl -fsSL "https://api.github.com/repos/${owner}/${repo}/releases/latest" 2>/dev/null \
        | grep '"tag_name"' | head -1 | cut -d'"' -f4)"

    if [ -n "${tag}" ]; then
        echo "${tag}"
    else
        return 1
    fi
}
