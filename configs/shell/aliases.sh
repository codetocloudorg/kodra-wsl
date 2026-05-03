#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  Kodra WSL — Shell Aliases                                  ║
# ║  Sourced by ~/.bashrc or ~/.zshrc                           ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Navigation ────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# ── File listing (eza) ────────────────────────────────────────
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --git'
    alias la='eza -la --icons --group-directories-first --git'
    alias lt='eza --tree --level=2 --icons --group-directories-first'
else
    alias ll='ls -lhF --color=auto'
    alias la='ls -lhAF --color=auto'
    alias lt='tree -L 2'
fi

# ── File operations ───────────────────────────────────────────
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
fi

if command -v rg &>/dev/null; then
    alias grep='rg'
fi

if command -v fd &>/dev/null; then
    alias find='fd'
fi

# ── Git ───────────────────────────────────────────────────────
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git log --oneline'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gpl='git pull'

# ── Docker ────────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlog='docker logs -f'
alias dex='docker exec -it'
alias dprune='docker system prune'

# ── Kubernetes ────────────────────────────────────────────────
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias klog='kubectl logs -f'
alias kex='kubectl exec -it'
kns() { kubectl config set-context --current --namespace="$1"; }

# ── Azure ─────────────────────────────────────────────────────
alias azl='az login'
alias azg='az group list -o table'
alias azs='az account show -o table'

# ── Terraform ─────────────────────────────────────────────────
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'

# ── Kodra ─────────────────────────────────────────────────────
alias kd='kodra doctor'
alias ku='kodra update'
alias kr='kodra repair'

# ── WSL-specific ──────────────────────────────────────────────
alias explorer='explorer.exe .'
alias winpath='wslpath -w'
if [[ -n "$WIN_USER" ]]; then
    alias winhome="cd /mnt/c/Users/$WIN_USER"
fi

# ── Miscellaneous ─────────────────────────────────────────────
alias ports='ss -tlnp'
alias myip='curl -s ifconfig.me'
alias weather='curl -s wttr.in'
alias reload='source ~/.bashrc'
alias cls='clear'
