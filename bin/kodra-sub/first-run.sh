#!/usr/bin/env bash
#
# Kodra WSL First-Run Setup
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

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

# Try to get GitHub info if authenticated
GH_GIT_NAME=""
GH_GIT_EMAIL=""
if command -v gh &> /dev/null && gh auth status &>/dev/null; then
    GH_GIT_NAME=$(gh api user --jq '.name // empty' 2>/dev/null)
    GH_GIT_EMAIL=$(gh api user --jq '.email // empty' 2>/dev/null)
    # If no public email, try to get the noreply email
    if [ -z "$GH_GIT_EMAIL" ]; then
        GH_LOGIN=$(gh api user --jq '.login // empty' 2>/dev/null)
        GH_ID=$(gh api user --jq '.id // empty' 2>/dev/null)
        if [ -n "$GH_ID" ] && [ -n "$GH_LOGIN" ]; then
            GH_GIT_EMAIL="${GH_ID}+${GH_LOGIN}@users.noreply.github.com"
        fi
    fi
fi

# --- Git Name ---
if [ -n "$GIT_NAME" ]; then
    echo -e "  ${C_GREEN}✔${C_RESET} Git name: ${C_CYAN}$GIT_NAME${C_RESET}"
    echo -e "    ${C_GRAY}(Press Enter to keep, or type a new name)${C_RESET}"

    # Build options
    OPTIONS=()
    OPTIONS+=("$GIT_NAME")
    if [ -n "$GH_GIT_NAME" ] && [ "$GH_GIT_NAME" != "$GIT_NAME" ]; then
        OPTIONS+=("$GH_GIT_NAME")
    fi

    if command -v gum &> /dev/null && [ -t 0 ] && [ ${#OPTIONS[@]} -gt 1 ]; then
        echo ""
        CHOSEN_NAME=$(printf '%s\n' "${OPTIONS[@]}" "Enter a new name" | gum choose 2>/dev/null)
        if [ "$CHOSEN_NAME" = "Enter a new name" ]; then
            CHOSEN_NAME=$(gum input --placeholder "Your name" 2>/dev/null)
        fi
    else
        printf "    Name [%s]: " "$GIT_NAME"
        read -r CHOSEN_NAME
        [ -z "$CHOSEN_NAME" ] && CHOSEN_NAME="$GIT_NAME"
    fi

    if [ -n "$CHOSEN_NAME" ] && [ "$CHOSEN_NAME" != "$GIT_NAME" ]; then
        git config --global user.name "$CHOSEN_NAME"
        echo -e "  ${C_GREEN}✔${C_RESET} Git name updated to: ${C_CYAN}$CHOSEN_NAME${C_RESET}"
    fi
else
    # No existing name — offer GitHub or manual entry
    if [ -n "$GH_GIT_NAME" ]; then
        echo -e "  ${C_CYAN}▶${C_RESET} Found GitHub name: ${C_CYAN}$GH_GIT_NAME${C_RESET}"
        if command -v gum &> /dev/null && [ -t 0 ]; then
            CHOSEN_NAME=$(printf '%s\n' "$GH_GIT_NAME" "Enter a different name" | gum choose 2>/dev/null)
            if [ "$CHOSEN_NAME" = "Enter a different name" ]; then
                CHOSEN_NAME=$(gum input --placeholder "Your name" 2>/dev/null)
            fi
        else
            printf "    Use '%s'? (Enter to accept, or type a new name): " "$GH_GIT_NAME"
            read -r CHOSEN_NAME
            [ -z "$CHOSEN_NAME" ] && CHOSEN_NAME="$GH_GIT_NAME"
        fi
    else
        echo -e "  ${C_CYAN}▶${C_RESET} Enter your name for Git commits:"
        read -p "    Name: " CHOSEN_NAME
    fi

    if [ -n "$CHOSEN_NAME" ]; then
        git config --global user.name "$CHOSEN_NAME"
        echo -e "  ${C_GREEN}✔${C_RESET} Git name set to: ${C_CYAN}$CHOSEN_NAME${C_RESET}"
    fi
fi

# --- Git Email ---
if [ -n "$GIT_EMAIL" ]; then
    echo -e "  ${C_GREEN}✔${C_RESET} Git email: ${C_CYAN}$GIT_EMAIL${C_RESET}"
    echo -e "    ${C_GRAY}(Press Enter to keep, or type a new email)${C_RESET}"

    OPTIONS=()
    OPTIONS+=("$GIT_EMAIL")
    if [ -n "$GH_GIT_EMAIL" ] && [ "$GH_GIT_EMAIL" != "$GIT_EMAIL" ]; then
        OPTIONS+=("$GH_GIT_EMAIL")
    fi

    if command -v gum &> /dev/null && [ -t 0 ] && [ ${#OPTIONS[@]} -gt 1 ]; then
        echo ""
        CHOSEN_EMAIL=$(printf '%s\n' "${OPTIONS[@]}" "Enter a new email" | gum choose 2>/dev/null)
        if [ "$CHOSEN_EMAIL" = "Enter a new email" ]; then
            CHOSEN_EMAIL=$(gum input --placeholder "you@example.com" 2>/dev/null)
        fi
    else
        printf "    Email [%s]: " "$GIT_EMAIL"
        read -r CHOSEN_EMAIL
        [ -z "$CHOSEN_EMAIL" ] && CHOSEN_EMAIL="$GIT_EMAIL"
    fi

    if [ -n "$CHOSEN_EMAIL" ] && [ "$CHOSEN_EMAIL" != "$GIT_EMAIL" ]; then
        git config --global user.email "$CHOSEN_EMAIL"
        echo -e "  ${C_GREEN}✔${C_RESET} Git email updated to: ${C_CYAN}$CHOSEN_EMAIL${C_RESET}"
    fi
else
    if [ -n "$GH_GIT_EMAIL" ]; then
        echo -e "  ${C_CYAN}▶${C_RESET} Found GitHub email: ${C_CYAN}$GH_GIT_EMAIL${C_RESET}"
        if command -v gum &> /dev/null && [ -t 0 ]; then
            CHOSEN_EMAIL=$(printf '%s\n' "$GH_GIT_EMAIL" "Enter a different email" | gum choose 2>/dev/null)
            if [ "$CHOSEN_EMAIL" = "Enter a different email" ]; then
                CHOSEN_EMAIL=$(gum input --placeholder "you@example.com" 2>/dev/null)
            fi
        else
            printf "    Use '%s'? (Enter to accept, or type a new email): " "$GH_GIT_EMAIL"
            read -r CHOSEN_EMAIL
            [ -z "$CHOSEN_EMAIL" ] && CHOSEN_EMAIL="$GH_GIT_EMAIL"
        fi
    else
        echo -e "  ${C_CYAN}▶${C_RESET} Enter your email for Git commits:"
        read -p "    Email: " CHOSEN_EMAIL
    fi

    if [ -n "$CHOSEN_EMAIL" ]; then
        git config --global user.email "$CHOSEN_EMAIL"
        echo -e "  ${C_GREEN}✔${C_RESET} Git email set to: ${C_CYAN}$CHOSEN_EMAIL${C_RESET}"
    fi
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
        echo -e "    ${C_GRAY}(Press Y for yes, N for no)${C_RESET}"
        read -p "    Login to GitHub now? [Y/n] " -n 1 -r REPLY
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            gh auth login
            
            # Remind about Copilot CLI
            if gh auth status &>/dev/null; then
                echo ""
                echo -e "  ${C_GREEN}✔${C_RESET} GitHub authenticated"
                echo -e "  ${C_CYAN}ℹ${C_RESET} Copilot CLI: run 'copilot' then '/login' to authenticate"
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
        echo -e "    ${C_GRAY}(Press Y for yes, N for no)${C_RESET}"
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
        echo -e "    ${C_GRAY}(Press Y for yes, N for no)${C_RESET}"
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
