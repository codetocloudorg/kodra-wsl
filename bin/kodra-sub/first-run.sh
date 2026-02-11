#!/usr/bin/env bash
#
# Kodra WSL First-Run Setup
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# If stdin is not a terminal (i.e., script is piped), redirect from /dev/tty
if [ ! -t 0 ]; then
    exec < /dev/tty
fi

# Colors
C_RESET='\033[0m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_CYAN='\033[0;36m'
C_WHITE='\033[1;37m'
C_GRAY='\033[0;90m'

# Skip flag
if [ "$1" = "--skip" ]; then
    exit 0
fi

echo ""
echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}  ${C_WHITE}Kodra WSL First-Time Setup${C_RESET}                                    ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

# Git configuration
echo -e "${C_WHITE}Git Configuration${C_RESET}"
echo ""

GIT_NAME=$(git config --global user.name 2>/dev/null)
GIT_EMAIL=$(git config --global user.email 2>/dev/null)

if [ -z "$GIT_NAME" ]; then
    echo -e "  ${C_CYAN}▶${C_RESET} Enter your name for Git commits:"
    read -p "    Name: " GIT_NAME
    if [ -n "$GIT_NAME" ]; then
        git config --global user.name "$GIT_NAME"
        echo -e "  ${C_GREEN}✔${C_RESET} Git name set"
    fi
else
    echo -e "  ${C_GREEN}✔${C_RESET} Git name: $GIT_NAME"
fi

if [ -z "$GIT_EMAIL" ]; then
    echo -e "  ${C_CYAN}▶${C_RESET} Enter your email for Git commits:"
    read -p "    Email: " GIT_EMAIL
    if [ -n "$GIT_EMAIL" ]; then
        git config --global user.email "$GIT_EMAIL"
        echo -e "  ${C_GREEN}✔${C_RESET} Git email set"
    fi
else
    echo -e "  ${C_GREEN}✔${C_RESET} Git email: $GIT_EMAIL"
fi

# Set useful Git defaults
git config --global init.defaultBranch main 2>/dev/null
git config --global pull.rebase false 2>/dev/null
git config --global core.autocrlf input 2>/dev/null

echo ""

# GitHub CLI
echo -e "${C_WHITE}GitHub Authentication${C_RESET}"
echo ""

if command -v gh &> /dev/null; then
    if gh auth status &>/dev/null; then
        GH_USER=$(gh api user --jq '.login' 2>/dev/null)
        echo -e "  ${C_GREEN}✔${C_RESET} GitHub CLI authenticated as ${C_CYAN}$GH_USER${C_RESET}"
    else
        echo -e "  ${C_YELLOW}⚠${C_RESET} GitHub CLI not authenticated"
        echo ""
        read -p "    Login to GitHub now? [Y/n] " -n 1 -r REPLY
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            gh auth login
            
            # Install Copilot extension if authenticated
            if gh auth status &>/dev/null; then
                echo ""
                echo -e "  ${C_CYAN}▶${C_RESET} Installing GitHub Copilot CLI..."
                gh extension install github/gh-copilot 2>/dev/null || true
                echo -e "  ${C_GREEN}✔${C_RESET} GitHub Copilot CLI installed"
            fi
        fi
    fi
else
    echo -e "  ${C_YELLOW}⚠${C_RESET} GitHub CLI not installed"
fi

echo ""

# Azure CLI
echo -e "${C_WHITE}Azure Authentication${C_RESET}"
echo ""

if command -v az &> /dev/null; then
    if az account show &>/dev/null; then
        AZ_ACCOUNT=$(az account show --query name -o tsv 2>/dev/null)
        echo -e "  ${C_GREEN}✔${C_RESET} Azure CLI authenticated: ${C_CYAN}$AZ_ACCOUNT${C_RESET}"
    else
        echo -e "  ${C_YELLOW}⚠${C_RESET} Azure CLI not authenticated"
        echo ""
        read -p "    Login to Azure now? [Y/n] " -n 1 -r REPLY
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            az login
        fi
    fi
else
    echo -e "  ${C_YELLOW}⚠${C_RESET} Azure CLI not installed"
fi

echo ""

# Docker test
echo -e "${C_WHITE}Docker${C_RESET}"
echo ""

if command -v docker &> /dev/null; then
    if docker info &>/dev/null; then
        echo -e "  ${C_GREEN}✔${C_RESET} Docker is running"
    else
        echo -e "  ${C_YELLOW}⚠${C_RESET} Docker daemon not running"
        echo ""
        read -p "    Start Docker now? [Y/n] " -n 1 -r REPLY
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            if command -v systemctl &> /dev/null && systemctl is-system-running &> /dev/null 2>&1; then
                sudo systemctl start docker
            else
                sudo service docker start
            fi
            sleep 2
            if docker info &>/dev/null; then
                echo -e "  ${C_GREEN}✔${C_RESET} Docker started"
            fi
        fi
    fi
else
    echo -e "  ${C_YELLOW}⚠${C_RESET} Docker not installed"
fi

echo ""
echo -e "${C_GREEN}Setup complete!${C_RESET}"
echo ""
echo -e "  ${C_GRAY}Run 'kodra doctor' to verify everything is working${C_RESET}"
echo ""
