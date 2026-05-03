#!/usr/bin/env bash
set -e
#
# Kodra WSL Dev — Development environment setup
#
# Usage:
#   kodra dev [setup|node|python|go|rust|java|dotnet]
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_dev_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra dev [setup|node|python|go|rust|java|dotnet]"
    echo ""
    echo -e "  ${C_BOLD}Subcommands:${C_RESET}"
    echo -e "    setup     Interactive language runtime selection"
    echo -e "    node      Install Node.js via mise (or nvm fallback)"
    echo -e "    python    Install Python via mise (or deadsnakes PPA)"
    echo -e "    go        Install Go from golang.org"
    echo -e "    rust      Install Rust via rustup"
    echo -e "    java      Install Java via SDKMAN"
    echo -e "    dotnet    Install .NET via Microsoft packages"
    echo ""
}

dev_node() {
    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Installing Node.js..."
    if command_exists mise; then
        mise use --global node@lts 2>/dev/null
        show_success "Node.js installed via mise: $(node --version 2>/dev/null || echo "pending shell reload")"
    elif command_exists nvm; then
        nvm install --lts 2>/dev/null
        show_success "Node.js installed via nvm: $(node --version 2>/dev/null || echo "pending shell reload")"
    else
        # Install via NodeSource
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &>/dev/null
        sudo apt-get install -y nodejs &>/dev/null
        show_success "Node.js installed: $(node --version 2>/dev/null || echo "installed")"
    fi
}

dev_python() {
    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Installing Python..."
    if command_exists mise; then
        mise use --global python@latest 2>/dev/null
        show_success "Python installed via mise: $(python3 --version 2>/dev/null || echo "pending shell reload")"
    else
        sudo apt-get update &>/dev/null
        sudo apt-get install -y python3 python3-pip python3-venv &>/dev/null
        show_success "Python installed: $(python3 --version 2>/dev/null || echo "installed")"
    fi
}

dev_go() {
    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Installing Go..."
    if command_exists mise; then
        mise use --global go@latest 2>/dev/null
        show_success "Go installed via mise: $(go version 2>/dev/null || echo "pending shell reload")"
    else
        local arch
        arch="$(dpkg --print-architecture)"
        local go_version
        go_version="$(curl -fsSL 'https://go.dev/VERSION?m=text' 2>/dev/null | head -1)"
        if [ -n "${go_version}" ]; then
            curl -fsSL "https://go.dev/dl/${go_version}.linux-${arch}.tar.gz" | sudo tar -C /usr/local -xz 2>/dev/null
            add_to_path "/usr/local/go/bin"
            show_success "Go installed: ${go_version}"
        else
            show_error "Failed to determine latest Go version."
            return 1
        fi
    fi
}

dev_rust() {
    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Installing Rust..."
    if command_exists rustup; then
        rustup update 2>/dev/null
        show_success "Rust updated: $(rustc --version 2>/dev/null || echo "installed")"
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>/dev/null
        # shellcheck disable=SC1091
        source "${HOME}/.cargo/env" 2>/dev/null || true
        show_success "Rust installed: $(rustc --version 2>/dev/null || echo "pending shell reload")"
    fi
}

dev_java() {
    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Installing Java via SDKMAN..."
    if [ -d "${HOME}/.sdkman" ]; then
        # shellcheck disable=SC1091
        source "${HOME}/.sdkman/bin/sdkman-init.sh" 2>/dev/null || true
        sdk install java 2>/dev/null || true
        show_success "Java installed via SDKMAN."
    else
        curl -fsSL "https://get.sdkman.io" | bash 2>/dev/null
        # shellcheck disable=SC1091
        source "${HOME}/.sdkman/bin/sdkman-init.sh" 2>/dev/null || true
        sdk install java 2>/dev/null || true
        show_success "SDKMAN + Java installed. Run 'source ~/.bashrc' to activate."
    fi
}

dev_dotnet() {
    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Installing .NET SDK..."
    if command_exists dotnet; then
        show_info ".NET is already installed: $(dotnet --version 2>/dev/null)"
        return 0
    fi

    # Install via Microsoft package feed
    local os_version
    os_version="$(lsb_release -rs 2>/dev/null || echo "24.04")"
    curl -fsSL "https://packages.microsoft.com/config/ubuntu/${os_version}/packages-microsoft-prod.deb" -o packages-microsoft-prod.deb 2>/dev/null
    sudo dpkg -i packages-microsoft-prod.deb &>/dev/null || true
    rm -f packages-microsoft-prod.deb
    sudo apt-get update &>/dev/null
    sudo apt-get install -y dotnet-sdk-8.0 &>/dev/null
    show_success ".NET SDK installed: $(dotnet --version 2>/dev/null || echo "installed")"
}

dev_setup() {
    if command_exists gum; then
        local selected
        selected="$(gum choose --no-limit \
            --header "Select language runtimes to install:" \
            "node     — Node.js (JavaScript/TypeScript)" \
            "python   — Python 3" \
            "go       — Go (Golang)" \
            "rust     — Rust" \
            "java     — Java (SDKMAN)" \
            "dotnet   — .NET SDK")"

        if [ -z "${selected}" ]; then
            echo -e "  ${C_DIM}No runtimes selected.${C_RESET}"
            return 0
        fi

        while IFS= read -r line; do
            local runtime
            runtime="$(echo "${line}" | awk '{print $1}')"
            case "${runtime}" in
                node)   dev_node ;;
                python) dev_python ;;
                go)     dev_go ;;
                rust)   dev_rust ;;
                java)   dev_java ;;
                dotnet) dev_dotnet ;;
            esac
        done <<< "${selected}"
    else
        echo -e "  ${C_BOLD}Available runtimes:${C_RESET}"
        echo -e "    node, python, go, rust, java, dotnet"
        echo ""
        echo -e "  ${C_DIM}Install gum for interactive selection, or run: kodra dev <runtime>${C_RESET}"
    fi
}

case "${1:-setup}" in
    -h|--help|help)
        show_dev_help
        ;;
    setup)
        dev_setup
        ;;
    node|nodejs)
        dev_node
        ;;
    python|python3)
        dev_python
        ;;
    go|golang)
        dev_go
        ;;
    rust)
        dev_rust
        ;;
    java)
        dev_java
        ;;
    dotnet|.net)
        dev_dotnet
        ;;
    *)
        show_error "Unknown runtime: $1"
        show_dev_help
        exit 1
        ;;
esac
