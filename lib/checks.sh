#!/usr/bin/env bash
#
# Kodra WSL Preflight Validation
#
# System checks run before installation to ensure the environment is ready.
# WSL-specific: validates WSL2, systemd, disk space, connectivity, etc.
#

_KODRA_CHECKS_PASSED=0
_KODRA_CHECKS_WARNED=0
_KODRA_CHECKS_FAILED=0

# Record a check result
_record_check() {
    local name="$1"
    local status="$2"
    local detail="${3:-}"

    case "${status}" in
        ok)   _KODRA_CHECKS_PASSED=$((_KODRA_CHECKS_PASSED + 1)) ;;
        warn) _KODRA_CHECKS_WARNED=$((_KODRA_CHECKS_WARNED + 1)) ;;
        fail) _KODRA_CHECKS_FAILED=$((_KODRA_CHECKS_FAILED + 1)) ;;
    esac

    # Use show_check from ui.sh if available, else fall back
    if declare -f show_check &>/dev/null; then
        show_check "${name}" "${status}" "${detail}"
    else
        case "${status}" in
            ok)   echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} ${name} ${C_DIM}${detail}${C_RESET}" ;;
            warn) echo -e "    ${C_YELLOW}${BOX_WARN}${C_RESET} ${name} ${C_DIM}${detail}${C_RESET}" ;;
            fail) echo -e "    ${C_RED}${BOX_CROSS}${C_RESET} ${name} ${C_DIM}${detail}${C_RESET}" ;;
        esac
    fi
}

# Run all checks
run_all_checks() {
    _KODRA_CHECKS_PASSED=0
    _KODRA_CHECKS_WARNED=0
    _KODRA_CHECKS_FAILED=0

    check_os
    check_wsl_version
    check_kernel_version
    check_systemd
    check_memory
    check_disk_space
    check_internet
    check_dns
    check_sudo
    check_apt
    check_shell
    check_locale
    check_required_packages
    check_docker_prerequisites

    show_checks_summary
    return ${_KODRA_CHECKS_FAILED}
}

# Check OS is Ubuntu
check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "${ID}" = "ubuntu" ]; then
            _record_check "Operating System" "ok" "${PRETTY_NAME}"
        else
            _record_check "Operating System" "warn" "${PRETTY_NAME} (expected Ubuntu)"
        fi
    else
        _record_check "Operating System" "fail" "/etc/os-release not found"
    fi
}

# Check WSL version (require WSL2, not WSL1)
check_wsl_version() {
    if grep -qEi '(microsoft|wsl)' /proc/version 2>/dev/null; then
        # WSL2 has a microsoft-standard kernel; WSL1 uses a Windows kernel
        if grep -qi 'microsoft-standard' /proc/version 2>/dev/null || \
           [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
            _record_check "WSL Version" "ok" "WSL2 detected"
        else
            _record_check "WSL Version" "warn" "WSL detected but may be WSL1"
        fi
    else
        _record_check "WSL Version" "warn" "Not running in WSL"
    fi
}

# Check disk space (need at least 2GB free)
check_disk_space() {
    local free_kb
    free_kb="$(df --output=avail "${HOME}" 2>/dev/null | tail -1 | tr -d ' ')"
    if [ -n "${free_kb}" ]; then
        local free_mb=$((free_kb / 1024))
        if [ "${free_mb}" -ge 2048 ]; then
            _record_check "Disk Space" "ok" "${free_mb}MB free"
        elif [ "${free_mb}" -ge 1024 ]; then
            _record_check "Disk Space" "warn" "${free_mb}MB free (2GB+ recommended)"
        else
            _record_check "Disk Space" "fail" "${free_mb}MB free (need 2GB+)"
        fi
    else
        _record_check "Disk Space" "warn" "Could not determine free space"
    fi
}

# Check internet connectivity
check_internet() {
    if curl -fsSL --connect-timeout 5 https://github.com > /dev/null 2>&1; then
        _record_check "Internet" "ok" "Connected"
    elif curl -fsSL --connect-timeout 5 https://google.com > /dev/null 2>&1; then
        _record_check "Internet" "ok" "Connected"
    else
        _record_check "Internet" "fail" "No internet connection"
    fi
}

# Check sudo access
check_sudo() {
    if sudo -n true 2>/dev/null; then
        _record_check "Sudo Access" "ok" "Passwordless sudo available"
    elif sudo -v 2>/dev/null; then
        _record_check "Sudo Access" "ok" "Sudo available"
    else
        _record_check "Sudo Access" "fail" "Cannot obtain sudo"
    fi
}

# Check apt is functional
check_apt() {
    if command -v apt-get &>/dev/null; then
        _record_check "APT" "ok" "Package manager available"
    else
        _record_check "APT" "fail" "apt-get not found"
    fi
}

# Check systemd is enabled in /etc/wsl.conf
check_systemd() {
    if [ -f /etc/wsl.conf ] && grep -qi 'systemd\s*=\s*true' /etc/wsl.conf 2>/dev/null; then
        if pidof systemd &>/dev/null; then
            _record_check "Systemd" "ok" "Enabled and running"
        else
            _record_check "Systemd" "warn" "Enabled in wsl.conf but not running (restart WSL)"
        fi
    else
        _record_check "Systemd" "warn" "Not enabled in /etc/wsl.conf"
    fi
}

# Check Docker prerequisites
check_docker_prerequisites() {
    local issues=""
    if ! grep -q 'overlay' /proc/filesystems 2>/dev/null; then
        issues="overlay fs missing"
    fi

    if [ -z "${issues}" ]; then
        _record_check "Docker Prerequisites" "ok" "Ready"
    else
        _record_check "Docker Prerequisites" "warn" "${issues}"
    fi
}

# Check available memory (need at least 1GB)
check_memory() {
    local mem_total_kb
    mem_total_kb="$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')"
    if [ -n "${mem_total_kb}" ]; then
        local mem_total_mb=$((mem_total_kb / 1024))
        if [ "${mem_total_mb}" -ge 2048 ]; then
            _record_check "Memory" "ok" "${mem_total_mb}MB total"
        elif [ "${mem_total_mb}" -ge 1024 ]; then
            _record_check "Memory" "warn" "${mem_total_mb}MB total (2GB+ recommended)"
        else
            _record_check "Memory" "fail" "${mem_total_mb}MB total (need 1GB+)"
        fi
    else
        _record_check "Memory" "warn" "Could not determine memory"
    fi
}

# Check kernel version
check_kernel_version() {
    local kernel
    kernel="$(uname -r)"
    _record_check "Kernel" "ok" "${kernel}"
}

# Check current shell
check_shell() {
    local shell_name
    shell_name="$(basename "${SHELL}")"
    case "${shell_name}" in
        bash|zsh)
            _record_check "Shell" "ok" "${shell_name} (${SHELL})"
            ;;
        *)
            _record_check "Shell" "warn" "${shell_name} — bash or zsh recommended"
            ;;
    esac
}

# Check locale
check_locale() {
    local current_locale
    current_locale="$(locale 2>/dev/null | grep LANG= | head -1 | cut -d= -f2)"
    if [ -n "${current_locale}" ]; then
        if echo "${current_locale}" | grep -qi 'utf-\?8'; then
            _record_check "Locale" "ok" "${current_locale}"
        else
            _record_check "Locale" "warn" "${current_locale} (UTF-8 recommended)"
        fi
    else
        _record_check "Locale" "warn" "Could not determine locale"
    fi
}

# Check DNS resolution
check_dns() {
    if getent hosts github.com &>/dev/null; then
        _record_check "DNS" "ok" "Resolving"
    elif nslookup github.com &>/dev/null; then
        _record_check "DNS" "ok" "Resolving"
    else
        _record_check "DNS" "fail" "Cannot resolve github.com"
    fi
}

# Check required base packages are installed
check_required_packages() {
    local missing=""
    local required="curl wget git ca-certificates gnupg"

    for pkg in ${required}; do
        if ! command -v "${pkg}" &>/dev/null; then
            if [ -n "${missing}" ]; then
                missing="${missing}, ${pkg}"
            else
                missing="${pkg}"
            fi
        fi
    done

    if [ -z "${missing}" ]; then
        _record_check "Required Packages" "ok" "curl, wget, git, gnupg"
    else
        _record_check "Required Packages" "fail" "Missing: ${missing}"
    fi
}

# Show summary of all checks
show_checks_summary() {
    local total=$((_KODRA_CHECKS_PASSED + _KODRA_CHECKS_WARNED + _KODRA_CHECKS_FAILED))
    echo ""
    if [ "${_KODRA_CHECKS_FAILED}" -gt 0 ]; then
        echo -e "    ${C_RED}${BOX_CROSS}${C_RESET} ${_KODRA_CHECKS_FAILED} check(s) failed out of ${total}"
    elif [ "${_KODRA_CHECKS_WARNED}" -gt 0 ]; then
        echo -e "    ${C_YELLOW}${BOX_WARN}${C_RESET} All checks passed with ${_KODRA_CHECKS_WARNED} warning(s)"
    else
        echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} All ${total} checks passed"
    fi
}
