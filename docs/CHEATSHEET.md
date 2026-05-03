# Kodra WSL Cheatsheet — Your Terminal Power-Ups

Quick reference for every alias, shortcut, and function that Kodra WSL adds to your terminal.

---

## Navigation

| Alias | Command | Description |
|-------|---------|-------------|
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `....` | `cd ../../..` | Go up three directories |
| `ll` | `eza -la --icons --git` | Detailed list with icons and git status |
| `la` | `eza -a --icons` | List all files with icons |
| `lt` | `eza --tree --icons -L 2` | Tree view (2 levels deep) |

---

## Git

| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Show working tree status |
| `ga` | `git add` | Stage files |
| `gc` | `git commit` | Commit staged changes |
| `gp` | `git push` | Push to remote |
| `gl` | `git pull` | Pull from remote |
| `gd` | `git diff` | Show unstaged changes |
| `gco` | `git checkout` | Switch branches or restore files |
| `gb` | `git branch` | List or create branches |
| `glog` | `git log --oneline --graph --decorate -10` | Compact log with graph |

---

## Docker

| Alias | Command | Description |
|-------|---------|-------------|
| `d` | `docker` | Docker shorthand |
| `dc` | `docker compose` | Docker Compose (v2) |
| `dps` | `docker ps` | List running containers |
| `dpsa` | `docker ps -a` | List all containers |
| `di` | `docker images` | List images |
| `dex` | `docker exec -it` | Exec into a container |
| `dlogs` | `docker logs -f` | Follow container logs |

---

## Kubernetes

| Alias | Command | Description |
|-------|---------|-------------|
| `k` | `kubectl` | kubectl shorthand |
| `kgp` | `kubectl get pods` | List pods |
| `kgs` | `kubectl get services` | List services |
| `kgd` | `kubectl get deployments` | List deployments |
| `kgn` | `kubectl get nodes` | List nodes |
| `kctx` | `kubectl config get-contexts` | Show available contexts |
| `kns` | `kubectl config set-context --current --namespace` | Switch namespace |

---

## Azure

| Alias | Command | Description |
|-------|---------|-------------|
| `az-login` | `az login` | Login to Azure |
| `az-sub` | `az account show --query name -o tsv` | Show current subscription |
| `azd-up` | `azd up` | Deploy with Azure Developer CLI |
| `azd-down` | `azd down` | Tear down Azure resources |

---

## AI / Copilot

| Alias | Command | Description |
|-------|---------|-------------|
| `??` | `copilot -p` | Ask Copilot CLI anything |
| `explain` | `copilot -p "Explain this command:"` | Explain a command with AI |

---

## CLI Enhancements

| Alias | Command | Description |
|-------|---------|-------------|
| `cat` | `bat --paging=never` | Syntax-highlighted file viewing |
| `grep` | `grep --color=auto` | Colorized grep output |
| `df` | `df -h` | Human-readable disk usage |
| `du` | `du -h` | Human-readable directory sizes |
| `free` | `free -h` | Human-readable memory info |

---

## Kodra Commands

| Command | Description |
|---------|-------------|
| `kodra doctor` | Check system health and all tool versions |
| `kodra doctor --fix` | Auto-reinstall any missing tools |
| `kodra update` | Update all 25+ installed tools |
| `kodra repair` | Interactive repair menu |
| `kodra repair --all` | Repair everything automatically |
| `kodra setup` | Re-run first-time configuration |
| `kodra fetch` | Show system info (fastfetch) |
| `kodra version` | Show Kodra version |
| `kodra help` | Show all available commands |

---

## WSL-Specific

| Command / Feature | Description |
|-------------------|-------------|
| `explorer.exe .` | Open current directory in Windows Explorer |
| `code .` | Open current directory in VS Code |
| `/mnt/c/` | Access Windows C: drive from WSL |
| `wsl.exe --shutdown` | Restart WSL (from PowerShell) |
| `clip.exe` | Pipe output to Windows clipboard (`echo "hi" \| clip.exe`) |
| `powershell.exe` | Run PowerShell from WSL |

---

## Installed TUI Tools

| Tool | Launch Command | Description |
|------|---------------|-------------|
| lazygit | `lazygit` | Terminal UI for Git |
| lazydocker | `lazydocker` | Terminal UI for Docker |
| k9s | `k9s` | Terminal UI for Kubernetes |
| btop | `btop` | System resource monitor |
| fastfetch | `fastfetch` | System info display |

---

## FZF (Fuzzy Finder)

Kodra configures fzf with sensible defaults:

| Shortcut | Description |
|----------|-------------|
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+T` | Fuzzy find files |
| `Alt+C` | Fuzzy cd into directories |

fzf defaults configured by Kodra:

```
--height 40% --layout=reverse --border --info=inline
```

---

## Zoxide (Smart cd)

| Command | Description |
|---------|-------------|
| `z <query>` | Jump to a frequently used directory |
| `zi` | Interactive directory picker (with fzf) |

Zoxide learns your most-visited directories and lets you jump to them by partial name.

---

## Pro Tips

### Combine aliases

```bash
# Stage all, commit, and push
ga . && gc -m "feat: add auth" && gp

# Check pods then follow logs
kgp && k logs -f <pod-name>
```

### Use fzf everywhere

```bash
# Kill a process interactively
kill -9 $(ps aux | fzf | awk '{print $2}')

# Checkout a branch interactively
gco $(gb | fzf)

# Open a file in VS Code
code $(fzf)
```

### Docker workflows

```bash
# Stop all running containers
docker stop $(dps -q)

# Remove all stopped containers
docker rm $(dpsa -q)

# Exec into latest container
dex $(dps -q | head -1) bash
```

### Pipe to Windows clipboard

```bash
# Copy a file's contents
cat ~/.ssh/id_rsa.pub | clip.exe

# Copy command output
kodra doctor | clip.exe
```

### Quick system check

```bash
# Full health check + system info
kodra doctor && kodra fetch
```
