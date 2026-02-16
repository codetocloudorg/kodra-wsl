#!/usr/bin/env bash
#
# Kodra WSL Doctor - System health check
#
# Usage:
#   kodra doctor          Check system health (read-only)
#   kodra doctor --fix    Check and auto-fix issues
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Parse flags
FIX_MODE=false
for arg in "$@"; do
    case "$arg" in
        --fix|-f)
            FIX_MODE=true
            ;;
    esac
done

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
if [ "$FIX_MODE" = "true" ]; then
    echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────────╮${C_RESET}"
    echo -e "${C_CYAN}│${C_RESET}  ${C_WHITE}Kodra WSL Health Check${C_RESET}  ${C_YELLOW}(fix mode)${C_RESET}                            ${C_CYAN}│${C_RESET}"
    echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────────╯${C_RESET}"
else
    echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────────╮${C_RESET}"
    echo -e "${C_CYAN}│${C_RESET}  ${C_WHITE}Kodra WSL Health Check${C_RESET}                                        ${C_CYAN}│${C_RESET}"
    echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────────╯${C_RESET}"
fi
echo ""

# Map tool names to their installer scripts
get_installer() {
    local cmd="$1"
    case "$cmd" in
        oh-my-posh)  echo "$KODRA_DIR/install/terminal/oh-my-posh.sh" ;;
        az)          echo "$KODRA_DIR/install/cloud/azure-cli.sh" ;;
        azd)         echo "$KODRA_DIR/install/cloud/azd.sh" ;;
        bicep)       echo "$KODRA_DIR/install/cloud/bicep.sh" ;;
        terraform)   echo "$KODRA_DIR/install/cloud/terraform.sh" ;;
        tofu)        echo "$KODRA_DIR/install/cloud/opentofu.sh" ;;
        pwsh)        echo "$KODRA_DIR/install/cloud/powershell.sh" ;;
        docker)      echo "$KODRA_DIR/install/containers/docker-ce.sh" ;;
        lazydocker)  echo "$KODRA_DIR/install/containers/lazydocker.sh" ;;
        kubectl)     echo "$KODRA_DIR/install/cloud/kubectl.sh" ;;
        helm)        echo "$KODRA_DIR/install/cloud/helm.sh" ;;
        k9s)         echo "$KODRA_DIR/install/cloud/k9s.sh" ;;
        gh)          echo "$KODRA_DIR/install/cli-tools/github-cli.sh" ;;
        bat|batcat)  echo "$KODRA_DIR/install/cli-tools/bat.sh" ;;
        eza)         echo "$KODRA_DIR/install/cli-tools/eza.sh" ;;
        fzf)         echo "$KODRA_DIR/install/cli-tools/fzf.sh" ;;
        rg)          echo "$KODRA_DIR/install/cli-tools/ripgrep.sh" ;;
        zoxide)      echo "$KODRA_DIR/install/cli-tools/zoxide.sh" ;;
        lazygit)     echo "$KODRA_DIR/install/cli-tools/lazygit.sh" ;;
        btop)        echo "$KODRA_DIR/install/cli-tools/btop.sh" ;;
        fastfetch)   echo "$KODRA_DIR/install/cli-tools/fastfetch.sh" ;;
        yq)          echo "$KODRA_DIR/install/cli-tools/yq.sh" ;;
        *)           echo "" ;;
    esac
}

try_fix() {
    local name="$1"
    local cmd="$2"

    if [ "$FIX_MODE" != "true" ]; then
        return 1
    fi

    local installer
    installer=$(get_installer "$cmd")
    if [ -n "$installer" ] && [ -f "$installer" ]; then
        echo -e "  ${C_YELLOW}⟳${C_RESET} Attempting to install $name..."
        if bash "$installer" >/dev/null 2>&1; then
            # Refresh PATH
            export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$HOME/.azure/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"
            hash -r 2>/dev/null
            if command -v "$cmd" &> /dev/null; then
                echo -e "  ${C_GREEN}✔${C_RESET} $name ${C_GRAY}fixed!${C_RESET}"
                return 0
            fi
        fi
        echo -e "  ${C_RED}✖${C_RESET} $name ${C_GRAY}fix failed — run installer manually${C_RESET}"
    fi
    return 1
}

check_tool() {
    local name="$1"
    local cmd="$2"
    local version_cmd="${3:-$cmd --version 2>/dev/null | head -1}"
    
    if command -v "$cmd" &> /dev/null; then
        local version
        version=$(eval "$version_cmd" 2>/dev/null | head -1)
        echo -e "  ${C_GREEN}✔${C_RESET} $name ${C_GRAY}$version${C_RESET}"
        return 0
    else
        echo -e "  ${C_RED}✖${C_RESET} $name ${C_GRAY}not installed${C_RESET}"
        if try_fix "$name" "$cmd"; then
            return 0
        fi
        return 1
    fi
}

PASS=0
FAIL=0
FIXED=0

# Environment
echo -e "${C_WHITE}Environment${C_RESET}"
if grep -qEi "(microsoft|wsl)" /proc/version 2>/dev/null; then
    echo -e "  ${C_GREEN}✔${C_RESET} WSL2 ${C_GRAY}detected${C_RESET}"
    ((PASS++))
else
    echo -e "  ${C_YELLOW}⚠${C_RESET} WSL ${C_GRAY}not detected (native Linux)${C_RESET}"
fi

if check_tool "Ubuntu" "lsb_release" "lsb_release -rs"; then ((PASS++)); else ((FAIL++)); fi

# Shell integration check
if [ -f "$KODRA_DIR/configs/shell/kodra.sh" ]; then
    echo -e "  ${C_GREEN}✔${C_RESET} Shell integration ${C_GRAY}configured${C_RESET}"
    ((PASS++))
else
    echo -e "  ${C_RED}✖${C_RESET} Shell integration ${C_GRAY}missing${C_RESET}"
    if [ "$FIX_MODE" = "true" ]; then
        echo -e "  ${C_YELLOW}⟳${C_RESET} Running repair..."
        "$KODRA_DIR/bin/kodra-sub/repair.sh" --shell --path >/dev/null 2>&1 && \
            echo -e "  ${C_GREEN}✔${C_RESET} Shell integration ${C_GRAY}fixed!${C_RESET}" && ((FIXED++)) || \
            ((FAIL++))
    else
        ((FAIL++))
    fi
fi
echo ""

# Shell
echo -e "${C_WHITE}Shell${C_RESET}"
if check_tool "Oh My Posh" "oh-my-posh" "oh-my-posh version 2>/dev/null"; then ((PASS++)); else ((FAIL++)); fi
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
        echo -e "  ${C_YELLOW}⚠${C_RESET} Docker daemon ${C_GRAY}not running${C_RESET}"
        if [ "$FIX_MODE" = "true" ]; then
            echo -e "  ${C_YELLOW}⟳${C_RESET} Starting Docker daemon..."
            if command -v systemctl &> /dev/null && systemctl is-system-running &>/dev/null 2>&1; then
                sudo systemctl start docker 2>/dev/null
            else
                sudo service docker start 2>/dev/null
            fi
            sleep 2
            if docker info &>/dev/null; then
                echo -e "  ${C_GREEN}✔${C_RESET} Docker daemon ${C_GRAY}started!${C_RESET}"
                ((FIXED++))
            else
                echo -e "  ${C_RED}✖${C_RESET} Docker daemon ${C_GRAY}could not be started${C_RESET}"
            fi
        else
            echo -e "    ${C_GRAY}Start with: sudo service docker start${C_RESET}"
        fi
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
if check_tool "btop" "btop" "btop --version 2>/dev/null | head -1"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "fastfetch" "fastfetch" "fastfetch --version 2>/dev/null | head -1"; then ((PASS++)); else ((FAIL++)); fi
if check_tool "yq" "yq" "yq --version 2>/dev/null | awk '{print \$NF}'"; then ((PASS++)); else ((FAIL++)); fi
echo ""

# Summary
echo -e "${C_CYAN}────────────────────────────────────────────────────────────────────${C_RESET}"
if [ $FAIL -eq 0 ]; then
    if [ $FIXED -gt 0 ]; then
        echo -e "  ${C_GREEN}All checks passed!${C_RESET} ($PASS verified, $FIXED fixed)"
    else
        echo -e "  ${C_GREEN}All checks passed!${C_RESET} ($PASS tools verified)"
    fi
else
    echo -e "  ${C_GREEN}$PASS passed${C_RESET}, ${C_RED}$FAIL failed${C_RESET}$([ $FIXED -gt 0 ] && echo ", ${C_YELLOW}$FIXED fixed${C_RESET}")"
    echo ""
    if [ "$FIX_MODE" = "true" ]; then
        echo -e "  ${C_GRAY}Some tools could not be auto-fixed. Try reinstalling manually.${C_RESET}"
    else
        echo -e "  ${C_GRAY}Run 'kodra doctor --fix' to auto-fix missing tools${C_RESET}"
    fi
fi
echo ""
