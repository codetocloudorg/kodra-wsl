#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  Kodra WSL — Shell Helper Functions                         ║
# ║  Sourced by ~/.bashrc or ~/.zshrc                           ║
# ╚══════════════════════════════════════════════════════════════╝

# ── mkcd — create directory and cd into it ────────────────────
mkcd() {
    if [[ -z "$1" ]]; then
        echo "Usage: mkcd <directory>" >&2
        return 1
    fi
    mkdir -p "$1" && cd "$1" || return 1
}

# ── extract — universal archive extractor ─────────────────────
extract() {
    if [[ -z "$1" ]]; then
        echo "Usage: extract <archive>" >&2
        return 1
    fi
    if [[ ! -f "$1" ]]; then
        echo "extract: '$1' is not a file" >&2
        return 1
    fi
    case "$1" in
        *.tar.bz2) tar xjf "$1"   ;;
        *.tar.gz)  tar xzf "$1"   ;;
        *.tar.xz)  tar xJf "$1"   ;;
        *.tar.zst) tar --zstd -xf "$1" ;;
        *.bz2)     bunzip2 "$1"   ;;
        *.gz)      gunzip "$1"    ;;
        *.xz)      unxz "$1"     ;;
        *.tar)     tar xf "$1"    ;;
        *.tbz2)    tar xjf "$1"   ;;
        *.tgz)     tar xzf "$1"   ;;
        *.zip)     unzip "$1"     ;;
        *.7z)      7z x "$1"      ;;
        *.rar)     unrar x "$1"   ;;
        *.Z)       uncompress "$1" ;;
        *)
            echo "extract: unsupported format '$1'" >&2
            return 1
            ;;
    esac
}

# ── backup_file — quick timestamped backup ────────────────────
backup_file() {
    if [[ -z "$1" ]]; then
        echo "Usage: backup_file <file>" >&2
        return 1
    fi
    if [[ ! -f "$1" ]]; then
        echo "backup_file: '$1' not found" >&2
        return 1
    fi
    local stamp
    stamp=$(date +%Y%m%d_%H%M%S)
    cp -v "$1" "${1}.bak.${stamp}"
}

# ── serve — quick HTTP server ─────────────────────────────────
serve() {
    local port="${1:-8000}"
    echo "Serving on http://localhost:${port} ..."
    python3 -m http.server "$port"
}

# ── gitignore — fetch .gitignore template from GitHub ─────────
gitignore() {
    if [[ -z "$1" ]]; then
        echo "Usage: gitignore <language>" >&2
        echo "Examples: gitignore Python, gitignore Node, gitignore Go" >&2
        return 1
    fi
    local url="https://raw.githubusercontent.com/github/gitignore/main/${1}.gitignore"
    if curl -sfL "$url" -o .gitignore; then
        echo "Downloaded ${1}.gitignore → .gitignore"
    else
        echo "gitignore: template '${1}' not found" >&2
        return 1
    fi
}

# ── docker_cleanup — prune everything ─────────────────────────
docker_cleanup() {
    echo "Pruning stopped containers..."
    docker container prune -f
    echo "Pruning unused images..."
    docker image prune -af
    echo "Pruning unused volumes..."
    docker volume prune -f
    echo "Pruning unused networks..."
    docker network prune -f
    echo "Docker cleanup complete."
}

# ── kube_ctx — show or switch kubectl context ─────────────────
kube_ctx() {
    if [[ -z "$1" ]]; then
        kubectl config get-contexts
    else
        kubectl config use-context "$1"
    fi
}

# ── az_sub — show or switch Azure subscription ────────────────
az_sub() {
    if [[ -z "$1" ]]; then
        az account list -o table
    else
        az account set --subscription "$1" && \
            echo "Switched to subscription: $1"
    fi
}

# ── path_add — add directory to PATH (idempotent) ─────────────
path_add() {
    if [[ -z "$1" ]]; then
        echo "Usage: path_add <directory>" >&2
        return 1
    fi
    case ":${PATH}:" in
        *:"$1":*) echo "'$1' already in PATH" ;;
        *)        export PATH="$1:$PATH"
                  echo "Added '$1' to PATH" ;;
    esac
}

# ── path_show — display PATH entries one per line ─────────────
path_show() {
    echo "$PATH" | tr ':' '\n' | nl
}

# ── countdown — visual countdown timer ────────────────────────
countdown() {
    if [[ -z "$1" ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo "Usage: countdown <seconds>" >&2
        return 1
    fi
    local secs=$1
    while [[ $secs -gt 0 ]]; do
        printf "\r⏳ %02d:%02d " $((secs / 60)) $((secs % 60))
        sleep 1
        ((secs--))
    done
    printf "\r✅ Done!    \n"
}

# ── cheat — quick cheatsheet from cheat.sh ────────────────────
cheat() {
    if [[ -z "$1" ]]; then
        echo "Usage: cheat <command>" >&2
        return 1
    fi
    curl -s "cheat.sh/$1"
}

# ── wsl_ip — get the WSL2 instance IP address ─────────────────
wsl_ip() {
    ip -4 addr show eth0 2>/dev/null | grep -oP 'inet \K[\d.]+' || \
        hostname -I | awk '{print $1}'
}

# ── win_ip — get the Windows host IP from WSL ─────────────────
win_ip() {
    cat /etc/resolv.conf 2>/dev/null | grep nameserver | awk '{print $2}' | head -1
}
