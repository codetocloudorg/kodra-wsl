#!/usr/bin/env bash
#
# Kodra WSL Persistent Install Logging
#
# Structured logging to ~/.config/kodra/install.log with rotation.
#

KODRA_LOG_DIR="${HOME}/.config/kodra"
KODRA_LOG_PATH="${KODRA_LOG_DIR}/install.log"
KODRA_LOG_MAX_FILES=5
KODRA_LOG_MAX_SIZE=$((5 * 1024 * 1024))  # 5MB

# Initialize log (create dir, rotate if needed)
init_log() {
    mkdir -p "${KODRA_LOG_DIR}"

    # Rotate if log exceeds max size
    if [ -f "${KODRA_LOG_PATH}" ]; then
        local size
        size="$(stat -c%s "${KODRA_LOG_PATH}" 2>/dev/null || echo 0)"
        if [ "${size}" -ge "${KODRA_LOG_MAX_SIZE}" ]; then
            _rotate_logs
        fi
    fi

    # Write session header
    {
        echo ""
        echo "════════════════════════════════════════════════════════════"
        echo "Kodra WSL Log Session — $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "User: ${USER}  Host: $(hostname)  Kernel: $(uname -r)"
        echo "════════════════════════════════════════════════════════════"
    } >> "${KODRA_LOG_PATH}"
}

# Rotate log files (keep last N)
_rotate_logs() {
    # Shift existing rotated logs
    local i="${KODRA_LOG_MAX_FILES}"
    while [ "${i}" -gt 1 ]; do
        local prev=$((i - 1))
        if [ -f "${KODRA_LOG_PATH}.${prev}" ]; then
            mv "${KODRA_LOG_PATH}.${prev}" "${KODRA_LOG_PATH}.${i}"
        fi
        i="${prev}"
    done

    # Move current log to .1
    if [ -f "${KODRA_LOG_PATH}" ]; then
        mv "${KODRA_LOG_PATH}" "${KODRA_LOG_PATH}.1"
    fi
}

# Log info message
log_info() {
    local message="$1"
    _write_log "INFO" "${message}"
}

# Log error message
log_error() {
    local message="$1"
    _write_log "ERROR" "${message}"
}

# Log success message
log_success() {
    local message="$1"
    _write_log "OK" "${message}"
}

# Log warning message
log_warning() {
    local message="$1"
    _write_log "WARN" "${message}"
}

# Internal: write a log entry
_write_log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp="$(date +%Y-%m-%dT%H:%M:%S%z)"

    mkdir -p "${KODRA_LOG_DIR}"
    printf '[%s] %-5s %s\n' "${timestamp}" "${level}" "${message}" >> "${KODRA_LOG_PATH}"
}
