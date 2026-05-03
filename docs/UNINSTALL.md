# Uninstalling Kodra WSL

How to cleanly remove Kodra WSL from your system.

---

## Quick Uninstall

Run the built-in uninstaller:

```bash
bash ~/.kodra/uninstall.sh
```

This removes Kodra configurations, shell integration, and the `kodra` command. Installed tools (Docker, Azure CLI, etc.) are **not** removed — they continue to work independently.

---

## Selective Removal

If you only want to remove specific Kodra configurations:

### Remove shell integration only

Remove the Kodra lines from your shell config:

```bash
# Edit .bashrc and remove the Kodra WSL section
nano ~/.bashrc
```

Look for and delete these lines:

```bash
# Kodra WSL Configuration
[ -f "$HOME/.kodra/configs/shell/kodra.sh" ] && source "$HOME/.kodra/configs/shell/kodra.sh"
# Auto-start Docker in WSL
# Oh My Posh
eval "$(oh-my-posh init bash)"
```

### Remove aliases only

Delete the shell config file that defines aliases:

```bash
rm ~/.kodra/configs/shell/kodra.sh
```

---

## Full Removal

For a complete removal of everything Kodra installed, follow these steps in order:

### Step 1 — Run the Uninstaller

```bash
bash ~/.kodra/uninstall.sh
```

This handles:
- Removing the `kodra` symlink from `/usr/local/bin`
- Cleaning Kodra lines from `.bashrc` and `.zshrc`
- Removing the `~/.kodra` directory
- Removing the `~/.config/kodra` directory
- Removing the Docker auto-start helper

### Step 2 — Remove Oh My Posh

```bash
sudo rm -f /usr/local/bin/oh-my-posh
rm -rf ~/.cache/oh-my-posh
```

### Step 3 — Remove Nerd Fonts

```bash
rm -rf ~/.local/share/fonts/JetBrainsMono*
fc-cache -f
```

To remove the font from Windows Terminal, uninstall it from Windows:

```powershell
# From PowerShell
winget uninstall DEVCOM.JetBrainsMonoNerdFont
```

### Step 4 — Remove Individual Tools (Optional)

These tools were installed system-wide and persist after Kodra is removed. Remove only what you don't need:

```bash
# Docker CE
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo rm -rf /var/lib/docker /var/lib/containerd

# Azure CLI
sudo apt-get purge -y azure-cli
sudo rm -rf ~/.azure

# Azure Developer CLI (azd)
sudo rm -f /usr/local/bin/azd

# GitHub CLI
sudo apt-get purge -y gh

# Terraform
sudo rm -f /usr/local/bin/terraform

# OpenTofu
sudo rm -f /usr/local/bin/tofu

# kubectl
sudo rm -f /usr/local/bin/kubectl

# Helm
sudo rm -f /usr/local/bin/helm

# k9s
sudo rm -f /usr/local/bin/k9s

# Bicep
rm -rf ~/.azure/bin/bicep

# PowerShell 7
sudo apt-get purge -y powershell

# lazygit
sudo rm -f /usr/local/bin/lazygit

# lazydocker
sudo rm -f /usr/local/bin/lazydocker

# CLI tools
sudo apt-get purge -y bat eza fd-find ripgrep
sudo rm -f /usr/local/bin/fzf
sudo rm -f /usr/local/bin/zoxide
sudo rm -f /usr/local/bin/btop
sudo rm -f /usr/local/bin/fastfetch
sudo rm -f /usr/local/bin/yq

# Clean up
sudo apt-get autoremove -y
```

### Step 5 — Remove Leftover Config Files

```bash
# Tool-specific configs
rm -rf ~/.config/lazygit
rm -rf ~/.config/lazydocker
rm -rf ~/.config/bat
rm -rf ~/.config/btop
rm -rf ~/.config/k9s
```

### Step 6 — Remove WSL Configuration (Optional)

If you want to revert the WSL systemd configuration Kodra enabled:

```bash
sudo nano /etc/wsl.conf
```

Remove or comment out:

```ini
[boot]
systemd=true
```

> **Warning:** Disabling systemd will prevent Docker CE from running as a service.

---

## What Gets Removed

The `uninstall.sh` script removes:

| Item | Path |
|------|------|
| Kodra directory | `~/.kodra` |
| Kodra config | `~/.config/kodra` |
| Shell integration | Lines in `~/.bashrc` and `~/.zshrc` |
| `kodra` command | `/usr/local/bin/kodra` |
| Docker auto-start helper | `~/.local/bin/docker-wsl-start` |

---

## What Stays

The uninstaller intentionally preserves:

- **Installed tools** — Docker CE, Azure CLI, kubectl, Helm, fzf, bat, eza, and all other CLI tools remain installed and functional
- **System packages** — Packages installed via `apt` are not removed
- **Your data** — Docker volumes, Azure credentials, Git repos, and all personal files are untouched
- **WSL configuration** — `/etc/wsl.conf` changes (systemd) remain
- **Windows-side installs** — Windows Terminal, Nerd Fonts on Windows, and VS Code are not affected

---

## Reinstalling After Uninstall

To reinstall Kodra WSL after uninstalling:

```bash
curl -fsSL https://kodra.wsl.codetocloud.io/boot.sh | bash
```

The installer detects that tools are already present and skips re-downloading them, so reinstallation is faster than a fresh install.
