#!/usr/bin/env bash
#
# Kodra WSL Update
# Updates Kodra and all installed tools
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Colors
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_CYAN='\033[0;36m'
C_WHITE='\033[1;37m'
C_GRAY='\033[0;90m'

UPDATE_COUNT=0
UPDATE_FAIL=0

update_ok() {
    echo -e "  ${C_GREEN}✔${C_RESET} $1"
    ((UPDATE_COUNT++))
}

update_fail() {
    echo -e "  ${C_RED}✖${C_RESET} $1 ${C_GRAY}(update failed)${C_RESET}"
    ((UPDATE_FAIL++))
}

update_skip() {
    echo -e "  ${C_GRAY}─${C_RESET} $1 ${C_GRAY}(not installed)${C_RESET}"
}

echo ""
echo -e "${C_CYAN}╭──────────────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_CYAN}│${C_RESET}  ${C_WHITE}Kodra WSL Update${C_RESET}                                              ${C_CYAN}│${C_RESET}"
echo -e "${C_CYAN}╰──────────────────────────────────────────────────────────────────╯${C_RESET}"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Update Kodra itself
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${C_WHITE}Kodra WSL${C_RESET}"
echo ""
echo -e "  ${C_CYAN}▶${C_RESET} Pulling latest..."
cd "$KODRA_DIR"
if git fetch origin --quiet 2>/dev/null && git reset --hard origin/main --quiet 2>/dev/null; then
    update_ok "Kodra WSL updated to $(cat "$KODRA_DIR/VERSION" 2>/dev/null || echo 'latest')"
else
    update_fail "Kodra WSL repository"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# System packages
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${C_WHITE}System Packages${C_RESET}"
echo ""
echo -e "  ${C_CYAN}▶${C_RESET} Updating package lists..."
if sudo apt-get update -qq 2>/dev/null; then
    update_ok "Package lists updated"
else
    update_fail "Package lists"
fi

echo -e "  ${C_CYAN}▶${C_RESET} Upgrading system packages..."
if sudo apt-get upgrade -y -qq 2>/dev/null; then
    update_ok "System packages upgraded"
else
    update_fail "System packages"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Shell
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${C_WHITE}Shell${C_RESET}"
echo ""

# Oh My Posh
if command -v oh-my-posh &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating Oh My Posh..."
    if curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin" >/dev/null 2>&1; then
        update_ok "Oh My Posh $(oh-my-posh version 2>/dev/null)"
    else
        update_fail "Oh My Posh"
    fi
else
    update_skip "Oh My Posh"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Cloud Tools
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${C_WHITE}Cloud Tools${C_RESET}"
echo ""

# Azure CLI (apt-managed)
if command -v az &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating Azure CLI..."
    if sudo apt-get install -y -qq azure-cli >/dev/null 2>&1; then
        update_ok "Azure CLI $(az version --query '"azure-cli"' -o tsv 2>/dev/null)"
    else
        update_fail "Azure CLI"
    fi
else
    update_skip "Azure CLI"
fi

# Azure Developer CLI
if command -v azd &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating azd..."
    if curl -fsSL https://aka.ms/install-azd.sh | bash -s -- -a $(uname -m) 2>/dev/null | tail -1; then
        update_ok "azd $(azd version 2>/dev/null | head -1)"
    else
        update_fail "azd"
    fi
else
    update_skip "azd"
fi

# Bicep
if command -v bicep &> /dev/null || command -v az &> /dev/null; then
    if az bicep version &>/dev/null 2>&1; then
        echo -e "  ${C_CYAN}▶${C_RESET} Updating Bicep..."
        if az bicep upgrade >/dev/null 2>&1; then
            update_ok "Bicep $(bicep --version 2>/dev/null | awk '{print $4}')"
        else
            update_fail "Bicep"
        fi
    fi
fi

# Terraform
if command -v terraform &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating Terraform..."
    if sudo apt-get install -y -qq terraform >/dev/null 2>&1; then
        update_ok "Terraform $(terraform version 2>/dev/null | head -1 | awk '{print $2}')"
    else
        update_fail "Terraform"
    fi
else
    update_skip "Terraform"
fi

# OpenTofu
if command -v tofu &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating OpenTofu..."
    if sudo apt-get install -y -qq tofu >/dev/null 2>&1; then
        update_ok "OpenTofu $(tofu version 2>/dev/null | head -1 | awk '{print $2}')"
    else
        update_fail "OpenTofu"
    fi
else
    update_skip "OpenTofu"
fi

# PowerShell
if command -v pwsh &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating PowerShell..."
    if sudo apt-get install -y -qq powershell >/dev/null 2>&1; then
        update_ok "PowerShell $(pwsh --version 2>/dev/null | awk '{print $2}')"
    else
        update_fail "PowerShell"
    fi
else
    update_skip "PowerShell"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Containers
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${C_WHITE}Containers${C_RESET}"
echo ""

# Docker CE
if command -v docker &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating Docker CE..."
    if sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null 2>&1; then
        update_ok "Docker $(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')"
    else
        update_fail "Docker CE"
    fi
else
    update_skip "Docker CE"
fi

# lazydocker
if command -v lazydocker &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating lazydocker..."
    local_arch=$(uname -m)
    case "$local_arch" in
        x86_64) ld_arch="x86_64" ;;
        aarch64|arm64) ld_arch="arm64" ;;
        *) ld_arch="$local_arch" ;;
    esac
    LD_LATEST=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" 2>/dev/null | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')
    if [ -n "$LD_LATEST" ]; then
        if curl -fsSL "https://github.com/jesseduffield/lazydocker/releases/download/v${LD_LATEST}/lazydocker_${LD_LATEST}_Linux_${ld_arch}.tar.gz" | sudo tar xz -C /usr/local/bin lazydocker 2>/dev/null; then
            update_ok "lazydocker v${LD_LATEST}"
        else
            update_fail "lazydocker"
        fi
    else
        update_fail "lazydocker (could not fetch latest version)"
    fi
else
    update_skip "lazydocker"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Kubernetes
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${C_WHITE}Kubernetes${C_RESET}"
echo ""

# kubectl
if command -v kubectl &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating kubectl..."
    KUBE_LATEST=$(curl -fsSL https://dl.k8s.io/release/stable.txt 2>/dev/null)
    if [ -n "$KUBE_LATEST" ]; then
        local_arch=$(uname -m)
        case "$local_arch" in
            x86_64) k_arch="amd64" ;;
            aarch64|arm64) k_arch="arm64" ;;
            *) k_arch="$local_arch" ;;
        esac
        if curl -fsSL "https://dl.k8s.io/release/${KUBE_LATEST}/bin/linux/${k_arch}/kubectl" -o /tmp/kubectl 2>/dev/null; then
            sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl 2>/dev/null
            rm -f /tmp/kubectl
            update_ok "kubectl ${KUBE_LATEST}"
        else
            update_fail "kubectl"
        fi
    else
        update_fail "kubectl (could not fetch latest version)"
    fi
else
    update_skip "kubectl"
fi

# Helm
if command -v helm &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating Helm..."
    if curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash >/dev/null 2>&1; then
        update_ok "Helm $(helm version --short 2>/dev/null | awk -F'+' '{print $1}')"
    else
        update_fail "Helm"
    fi
else
    update_skip "Helm"
fi

# k9s
if command -v k9s &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating k9s..."
    local_arch=$(uname -m)
    case "$local_arch" in
        x86_64) k9_arch="amd64" ;;
        aarch64|arm64) k9_arch="arm64" ;;
        *) k9_arch="$local_arch" ;;
    esac
    K9S_LATEST=$(curl -fsSL "https://api.github.com/repos/derailed/k9s/releases/latest" 2>/dev/null | grep '"tag_name"' | sed 's/.*"\(.*\)".*/\1/')
    if [ -n "$K9S_LATEST" ]; then
        if curl -fsSL "https://github.com/derailed/k9s/releases/download/${K9S_LATEST}/k9s_Linux_${k9_arch}.tar.gz" | sudo tar xz -C /usr/local/bin k9s 2>/dev/null; then
            update_ok "k9s ${K9S_LATEST}"
        else
            update_fail "k9s"
        fi
    else
        update_fail "k9s (could not fetch latest version)"
    fi
else
    update_skip "k9s"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# CLI Tools
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${C_WHITE}CLI Tools${C_RESET}"
echo ""

# GitHub CLI (apt-managed)
if command -v gh &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating GitHub CLI..."
    if sudo apt-get install -y -qq gh >/dev/null 2>&1; then
        update_ok "GitHub CLI $(gh --version 2>/dev/null | head -1 | awk '{print $3}')"
    else
        update_fail "GitHub CLI"
    fi
    # Update extensions
    gh extension upgrade --all 2>/dev/null || true
else
    update_skip "GitHub CLI"
fi

# bat (apt-managed)
if command -v bat &> /dev/null || command -v batcat &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating bat..."
    if sudo apt-get install -y -qq bat >/dev/null 2>&1; then
        update_ok "bat"
    else
        update_fail "bat"
    fi
else
    update_skip "bat"
fi

# eza
if command -v eza &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating eza..."
    if sudo apt-get install -y -qq eza >/dev/null 2>&1; then
        update_ok "eza $(eza --version 2>/dev/null | head -1 | awk '{print $2}')"
    else
        update_fail "eza"
    fi
else
    update_skip "eza"
fi

# fzf
if command -v fzf &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating fzf..."
    if sudo apt-get install -y -qq fzf >/dev/null 2>&1; then
        update_ok "fzf $(fzf --version 2>/dev/null | awk '{print $1}')"
    else
        update_fail "fzf"
    fi
else
    update_skip "fzf"
fi

# ripgrep (apt-managed)
if command -v rg &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating ripgrep..."
    if sudo apt-get install -y -qq ripgrep >/dev/null 2>&1; then
        update_ok "ripgrep $(rg --version 2>/dev/null | head -1 | awk '{print $2}')"
    else
        update_fail "ripgrep"
    fi
else
    update_skip "ripgrep"
fi

# zoxide
if command -v zoxide &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating zoxide..."
    if curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh >/dev/null 2>&1; then
        update_ok "zoxide $(zoxide --version 2>/dev/null | awk '{print $2}')"
    else
        update_fail "zoxide"
    fi
else
    update_skip "zoxide"
fi

# lazygit
if command -v lazygit &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating lazygit..."
    local_arch=$(uname -m)
    case "$local_arch" in
        x86_64) lg_arch="x86_64" ;;
        aarch64|arm64) lg_arch="arm64" ;;
        *) lg_arch="$local_arch" ;;
    esac
    LG_LATEST=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" 2>/dev/null | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')
    if [ -n "$LG_LATEST" ]; then
        if curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LG_LATEST}/lazygit_${LG_LATEST}_Linux_${lg_arch}.tar.gz" | sudo tar xz -C /usr/local/bin lazygit 2>/dev/null; then
            update_ok "lazygit v${LG_LATEST}"
        else
            update_fail "lazygit"
        fi
    else
        update_fail "lazygit (could not fetch latest version)"
    fi
else
    update_skip "lazygit"
fi

# btop (apt-managed)
if command -v btop &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating btop..."
    if sudo apt-get install -y -qq btop >/dev/null 2>&1; then
        update_ok "btop"
    else
        update_fail "btop"
    fi
else
    update_skip "btop"
fi

# fastfetch
if command -v fastfetch &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating fastfetch..."
    if sudo apt-get install -y -qq fastfetch >/dev/null 2>&1; then
        update_ok "fastfetch"
    else
        update_fail "fastfetch"
    fi
else
    update_skip "fastfetch"
fi

# yq
if command -v yq &> /dev/null; then
    echo -e "  ${C_CYAN}▶${C_RESET} Updating yq..."
    local_arch=$(uname -m)
    case "$local_arch" in
        x86_64) yq_arch="amd64" ;;
        aarch64|arm64) yq_arch="arm64" ;;
        *) yq_arch="$local_arch" ;;
    esac
    if curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${yq_arch}" -o /tmp/yq 2>/dev/null; then
        sudo install -o root -g root -m 0755 /tmp/yq /usr/local/bin/yq 2>/dev/null
        rm -f /tmp/yq
        update_ok "yq $(yq --version 2>/dev/null | awk '{print $NF}')"
    else
        update_fail "yq"
    fi
else
    update_skip "yq"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Cleanup
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${C_WHITE}Cleanup${C_RESET}"
echo ""
sudo apt-get autoremove -y -qq >/dev/null 2>&1
update_ok "Removed unused packages"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${C_CYAN}────────────────────────────────────────────────────────────────────${C_RESET}"
if [ $UPDATE_FAIL -eq 0 ]; then
    echo -e "  ${C_GREEN}Update complete!${C_RESET} ($UPDATE_COUNT items updated)"
else
    echo -e "  ${C_GREEN}$UPDATE_COUNT updated${C_RESET}, ${C_RED}$UPDATE_FAIL failed${C_RESET}"
fi
echo ""
echo -e "  ${C_GRAY}Run 'kodra doctor' to verify all tools${C_RESET}"
echo ""
