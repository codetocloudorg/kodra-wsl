#!/usr/bin/env bash
#
# Kodra WSL Doctor - System health check
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Extend PATH with common tool locations
export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$HOME/.azure/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"

# Colors
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_CYAN='\033[0;36m'
C_WHITE='\033[1;37m'
C_GRAY='\033[0;90m'

echo ""
echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}  ${C_WHITE}Kodra WSL Health Check${C_RESET}                                        ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

check_tool() {
    local name="$1"
    local cmd="$2"
    local version_cmd="${3:-$cmd --version 2>/dev/null | head -1}"
    
    if command -v "$cmd" &> /dev/null; then
        local version=$(eval "$version_cmd" 2>/dev/null | head -1)
        echo -e "  ${C_GREEN}✔${C_RESET} $name ${C_GRAY}$version${C_RESET}"
        return 0
    else
        echo -e "  ${C_RED}✖${C_RESET} $name ${C_GRAY}not installed${C_RESET}"
        return 1
    fi
}

PASS=0
FAIL=0

# Environment
echo -e "${C_WHITE}Environment${C_RESET}"
if grep -qEi "(microsoft|wsl)" /proc/version 2>/dev/null; then
    echo -e "  ${C_GREEN}✔${C_RESET} WSL2 ${C_GRAY}detected${C_RESET}"
    ((PASS++))
else
    echo -e "  ${C_YELLOW}⚠${C_RESET} WSL ${C_GRAY}not detected (native Linux)${C_RESET}"
fi

if check_tool "Ubuntu" "lsb_release" "lsb_release -rs"; then ((PASS++)); else ((FAIL++)); fi
echo ""

# Shell
echo -e "${C_WHITE}Shell${C_RESET}"
if check_tool "Zsh" "zsh" "zsh --version | awk '{print \$2}'"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "Starship" "starship" "starship --version | head -1 | awk '{print \$2}'"; then ((PASS++)); else ((FAIL++)); fi
echo ""

# Cloud Tools
echo -e "${C_WHITE}Cloud Tools${C_RESET}"
if check_tool "Azure CLI" "az" "az version --query '\"azure-cli\"' -o tsv 2>/dev/null"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "azd" "azd" "azd version 2>/dev/null | head -1"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "Bicep" "bicep" "bicep --version 2>/dev/null | awk '{print \$4}'"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "Terraform" "terraform" "terraform version 2>/dev/null | head -1 | awk '{print \$2}'"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "OpenTofu" "tofu" "tofu version 2>/dev/null | head -1 | awk '{print \$2}'"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "PowerShell" "pwsh" "pwsh --version 2>/dev/null | awk '{print \$2}'"; then ((PASS++)); else ((FAIL++)); fi
echo ""

# Containers
echo -e "${C_WHITE}Containers${C_RESET}"
if check_tool "Docker" "docker" "docker --version 2>/dev/null | awk '{print \$3}' | tr -d ','"; then 
    ((PASS++))
    # Check if Docker daemon is running
    if docker info &>/dev/null; then
        echo -e "  ${C_GREEN}✔${C_RESET} Docker daemon ${C_GRAY}running${C_RESET}"
        ((PASS++))
    else
        echo -e "  ${C_YELLOW}⚠${C_RESET} Docker daemon ${C_GRAY}not running (start with: sudo service docker start)${C_RESET}"
    fi
else 
    ((FAIL++))
fi
if check_tool "lazydocker" "lazydocker"; then ((PASS++)); else ((FAIL++)); fi
echo ""

# Kubernetes
echo -e "${C_WHITE}Kubernetes${C_RESET}"
if check_tool "kubectl" "kubectl" "kubectl version --client -o json 2>/dev/null | jq -r '.clientVersion.gitVersion'"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "Helm" "helm" "helm version --short 2>/dev/null | awk -F'+' '{print \$1}'"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "k9s" "k9s" "k9s version --short 2>/dev/null | head -1"; then ((PASS++)); else ((FAIL++)); fi
echo ""

# CLI Tools
echo -e "${C_WHITE}CLI Tools${C_RESET}"
if check_tool "GitHub CLI" "gh" "gh --version 2>/dev/null | head -1 | awk '{print \$3}'"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "bat" "bat" "bat --version 2>/dev/null | awk '{print \$2}'" || check_tool "bat" "batcat" "batcat --version 2>/dev/null | awk '{print \$2}'"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "eza" "eza" "eza --version 2>/dev/null | head -1 | awk '{print \$2}'"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "fzf" "fzf" "fzf --version 2>/dev/null | awk '{print \$1}'"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "ripgrep" "rg" "rg --version 2>/dev/null | head -1 | awk '{print \$2}'"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "zoxide" "zoxide" "zoxide --version 2>/dev/null | awk '{print \$2}'"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "lazygit" "lazygit"; then ((PASS++)); else ((FAIL++)); fi
echo ""

# Summary
echo -e "${C_CYAN}────────────────────────────────────────────────────────────────────${C_RESET}"
if [ $FAIL -eq 0 ]; then
    echo -e "  ${C_GREEN}All checks passed!${C_RESET} ($PASS tools verified)"
else
    echo -e "  ${C_GREEN}$PASS passed${C_RESET}, ${C_RED}$FAIL failed${C_RESET}"
    echo ""
    echo -e "  ${C_GRAY}Run 'kodra update' to fix missing tools${C_RESET}"
fi
echo ""
