#!/usr/bin/env bash
#
# Kodra WSL Bootstrap Script
# A Code To Cloud Project ☁️
#
# https://kodra.wsl.codetocloud.io
#
# Usage: 
#   wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash
#   curl -fsSL https://kodra.wsl.codetocloud.io/boot.sh | bash
#
# Options:
#   --install    Skip menu, go straight to install
#   --uninstall  Skip menu, go straight to uninstall
#   --update     Skip menu, go straight to update
#

set -e

# Parse arguments
KODRA_ACTION=""
for arg in "$@"; do
    case $arg in
        --install|-i)
            KODRA_ACTION="install"
            shift
            ;;
        --uninstall|--remove|-u)
            KODRA_ACTION="uninstall"
            shift
            ;;
        --update|-U)
            KODRA_ACTION="update"
            shift
            ;;
    esac
done

KODRA_REPO="https://github.com/codetocloudorg/kodra-wsl.git"
KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Colors
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_PURPLE='\033[0;35m'
C_CYAN='\033[0;36m'
C_WHITE='\033[1;37m'
C_GRAY='\033[0;90m'
C_ORANGE='\033[38;5;208m'

# Clear screen for clean start
clear 2>/dev/null || true

# Animated gradient banner (WSL edition with Ubuntu orange + Windows blue)
echo ""
echo -e "\033[38;5;208m    ██╗  ██╗ ██████╗ ██████╗ ██████╗  █████╗     ██╗    ██╗███████╗██╗     \033[0m"
echo -e "\033[38;5;214m    ██║ ██╔╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗    ██║    ██║██╔════╝██║     \033[0m"
echo -e "\033[38;5;39m    █████╔╝ ██║   ██║██║  ██║██████╔╝███████║    ██║ █╗ ██║███████╗██║     \033[0m"
echo -e "\033[38;5;33m    ██╔═██╗ ██║   ██║██║  ██║██╔══██╗██╔══██║    ██║███╗██║╚════██║██║     \033[0m"
echo -e "\033[38;5;27m    ██║  ██╗╚██████╔╝██████╔╝██║  ██║██║  ██║    ╚███╔███╔╝███████║███████╗\033[0m"
echo -e "\033[38;5;21m    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚══╝╚══╝ ╚══════╝╚══════╝\033[0m"
echo ""
echo -e "\033[38;5;39m    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[38;5;147m              ☁️  W S L   E D I T I O N  •  W I N D O W S  1 1 +  ☁️\033[0m"
echo -e "\033[38;5;39m    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo -e "    ${C_GRAY}Agentic Azure engineering for Windows developers${C_RESET}"
echo -e "    ${C_GRAY}Docker CE • Azure CLI • Kubernetes • CLI Tools${C_RESET}"
echo ""

# If stdin is not a terminal (i.e., script is piped), redirect from /dev/tty
# This allows interactive prompts to work with: wget -qO- ... | bash
if [ ! -t 0 ]; then
    exec < /dev/tty
fi

# Helper functions
show_step() {
    echo -e "    ${C_CYAN}▶${C_RESET} $1"
}

show_done() {
    echo -e "    ${C_GREEN}✔${C_RESET} $1"
}

show_warn() {
    echo -e "    ${C_YELLOW}⚠${C_RESET} $1"
}

show_error() {
    echo -e "    ${C_RED}✖${C_RESET} $1"
}

# Detect WSL environment
detect_wsl() {
    if grep -qEi "(microsoft|wsl)" /proc/version 2>/dev/null; then
        return 0
    fi
    if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
        return 0
    fi
    return 1
}

# Get WSL version
get_wsl_version() {
    if [ -f /proc/version ]; then
        if grep -qi "wsl2" /proc/version 2>/dev/null; then
            echo "2"
        elif grep -qi "microsoft" /proc/version 2>/dev/null; then
            # Could be WSL1 or WSL2, check for WSL2 indicators
            if [ -d /run/WSL ]; then
                echo "2"
            else
                echo "1"
            fi
        fi
    fi
    echo "unknown"
}

# Check for WSL2 on Windows 11+
show_step "Detecting environment..."

IS_WSL=false
IS_AZURE_VM=false
WSL_VERSION="unknown"

if detect_wsl; then
    IS_WSL=true
    WSL_VERSION=$(get_wsl_version)
    if [ "$WSL_VERSION" = "2" ]; then
        show_done "WSL2 detected"
    elif [ "$WSL_VERSION" = "1" ]; then
        show_warn "WSL1 detected - WSL2 recommended for Docker"
        echo -e "    ${C_GRAY}Upgrade with: wsl --set-version Ubuntu-24.04 2${C_RESET}"
    fi
else
    # Check if running on Azure VM (for testing)
    if curl -s -H "Metadata:true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" 2>/dev/null | grep -q "azureenvironment"; then
        IS_AZURE_VM=true
        show_done "Azure VM detected (test environment)"
    elif [ -f /etc/os-release ] && grep -q "ubuntu" /etc/os-release 2>/dev/null; then
        show_warn "Native Ubuntu detected (non-WSL)"
        echo -e "    ${C_GRAY}For full desktop experience, use: https://kodra.codetocloud.io${C_RESET}"
        echo ""
        read -p "    Continue with CLI-only install? (y/N) " -n 1 -r REPLY
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    else
        show_error "Unsupported environment"
        echo -e "    ${C_GRAY}Kodra WSL requires WSL2 with Ubuntu 24.04${C_RESET}"
        exit 1
    fi
fi

# Check for Ubuntu 24.04+
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        show_warn "Kodra WSL is designed for Ubuntu. Your OS: $ID"
        read -p "    Continue anyway? (y/N) " -n 1 -r REPLY
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        show_done "Ubuntu detected: $VERSION_ID"
    fi
    
    VERSION_NUM=$(echo "$VERSION_ID" | cut -d. -f1)
    if [ "$VERSION_NUM" -lt 24 ]; then
        show_warn "Kodra WSL requires Ubuntu 24.04+. Your version: $VERSION_ID"
        read -p "    Continue anyway? (y/N) " -n 1 -r REPLY
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi
echo ""

# Check for required tools
show_step "Checking prerequisites..."
for cmd in git curl wget; do
    if ! command -v $cmd &> /dev/null; then
        show_step "Installing $cmd..."
        sudo apt-get update -qq
        sudo apt-get install -y -qq $cmd
    fi
done
show_done "Prerequisites ready"

# Export environment flags
export KODRA_IS_WSL="$IS_WSL"
export KODRA_WSL_VERSION="$WSL_VERSION"
export KODRA_IS_AZURE_VM="$IS_AZURE_VM"

# Clone or update repository
echo ""
if [ -d "$KODRA_DIR" ]; then
    show_step "Updating existing Kodra WSL installation..."
    cd "$KODRA_DIR"
    echo -e "    ${C_GRAY}Fetching latest changes from GitHub...${C_RESET}"
    git fetch origin --progress < /dev/null 2>&1 || true
    # Reset to origin/main to handle divergent branches
    git reset --hard origin/main < /dev/null 2>&1 || true
    show_done "Repository updated"
    KODRA_EXISTS=true
else
    show_step "Downloading Kodra WSL from GitHub..."
    echo -e "    ${C_GRAY}This may take a moment on slower connections...${C_RESET}"
    git clone --progress "$KODRA_REPO" "$KODRA_DIR" < /dev/null 2>&1
    show_done "Repository cloned to $KODRA_DIR"
    KODRA_EXISTS=false
fi
echo ""

# Action menu
cd "$KODRA_DIR"

# Handle actions - default to install for fresh installs, update for existing
if [ -n "$KODRA_ACTION" ]; then
    # Explicit action from command line
    case "$KODRA_ACTION" in
        install)
            echo -e "    ${C_PURPLE}Starting installation...${C_RESET}"
            echo ""
            bash ./install.sh "$@"
            ;;
        uninstall)
            echo -e "    ${C_YELLOW}Preparing to uninstall...${C_RESET}"
            echo ""
            bash ./uninstall.sh
            ;;
        update)
            echo -e "    ${C_CYAN}Updating Kodra WSL...${C_RESET}"
            echo ""
            bash ./bin/kodra update
            ;;
    esac
elif [ "$KODRA_EXISTS" = true ]; then
    # Existing installation - show menu
    echo -e "    ${C_WHITE}What would you like to do?${C_RESET}"
    echo ""
    echo -e "    ${C_CYAN}1)${C_RESET} Update Kodra WSL"
    echo -e "    ${C_CYAN}2)${C_RESET} Reinstall"
    echo -e "    ${C_CYAN}3)${C_RESET} Uninstall"
    echo -e "    ${C_CYAN}4)${C_RESET} Exit"
    echo ""
    
    printf "    Choose an option [1-4]: "
    read -n 1 -r REPLY
    echo
    echo ""
    
    case $REPLY in
        1)
            echo -e "    ${C_CYAN}Updating...${C_RESET}"
            bash ./bin/kodra update
            ;;
        2)
            echo -e "    ${C_PURPLE}Reinstalling...${C_RESET}"
            bash ./install.sh "$@"
            ;;
        3)
            echo -e "    ${C_YELLOW}Uninstalling...${C_RESET}"
            bash ./uninstall.sh
            ;;
        4)
            echo -e "    ${C_GRAY}Exiting...${C_RESET}"
            exit 0
            ;;
        *)
            echo -e "    ${C_YELLOW}Invalid option. Please choose 1-4.${C_RESET}"
            exit 1
            ;;
    esac
else
    # Fresh install - go straight to installation
    echo -e "    ${C_PURPLE}Starting installation...${C_RESET}"
    echo ""
    bash ./install.sh "$@"
fi
