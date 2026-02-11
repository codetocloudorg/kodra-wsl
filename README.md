<div align="center">

```
    ██╗  ██╗ ██████╗ ██████╗ ██████╗  █████╗     ██╗    ██╗███████╗██╗     
    ██║ ██╔╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗    ██║    ██║██╔════╝██║     
    █████╔╝ ██║   ██║██║  ██║██████╔╝███████║    ██║ █╗ ██║███████╗██║     
    ██╔═██╗ ██║   ██║██║  ██║██╔══██╗██╔══██║    ██║███╗██║╚════██║██║     
    ██║  ██╗╚██████╔╝██████╔╝██║  ██║██║  ██║    ╚███╔███╔╝███████║███████╗
    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚══╝╚══╝ ╚══════╝╚══════╝
```

**Agentic Azure engineering in WSL—cloud-native CLI tools for Windows developers.**

[![Version](https://img.shields.io/badge/version-0.3.0-blue?style=flat-square)](VERSION)
[![WSL2](https://img.shields.io/badge/WSL2-Ubuntu_24.04+-E95420?style=flat-square&logo=ubuntu&logoColor=white)](https://learn.microsoft.com/en-us/windows/wsl/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/vwfwq2EpXJ)

*A WSL-focused variant of [Kodra](https://github.com/codetocloudorg/kodra) • Developed by [Code To Cloud](https://www.codetocloud.io)*

</div>

---

**The WSL edition of Kodra.** All the CLI tools, Azure integrations, and GitHub Copilot—running natively in Windows Subsystem for Linux. Perfect for Windows developers who want the power of Linux tooling without leaving their desktop.

This is the **CLI-focused variant** of [Kodra Desktop](https://github.com/codetocloudorg/kodra). No GNOME desktop, no window tiling—just pure terminal productivity optimized for WSL2.

## Kodra WSL vs Kodra Desktop

| Feature | Kodra WSL | Kodra Desktop |
|---------|-----------|---------------|
| **Target Environment** | WSL2 on Windows 11 | Native Ubuntu 24.04+ |
| **Desktop Environment** | None (CLI only) | GNOME with theming |
| **Terminal** | Windows Terminal | Ghostty |
| **Docker** | Docker CE in WSL2 | Docker CE |
| **Azure Tools** | ✅ Full suite | ✅ Full suite |
| **GitHub Copilot CLI** | ✅ | ✅ |
| **VS Code** | Windows VS Code + WSL extension | Native VS Code |
| **Window Tiling** | Use Windows PowerToys | Tactile extension |

## Prerequisites

Before running the Kodra WSL installer, you need to set up a few things on Windows first.

### Step 1: Install Windows Terminal

Download and install Windows Terminal from the Microsoft Store:

1. Open **Microsoft Store** and search for "Windows Terminal"
2. Click **Install**
3. Or install via winget: `winget install Microsoft.WindowsTerminal`

### Step 2: Install WSL2 with Ubuntu

Open **PowerShell as Administrator** and run:

```powershell
# Install WSL2 with Ubuntu 24.04
wsl --install -d Ubuntu-24.04

# Restart your computer when prompted
```

After restarting:
1. Open **Ubuntu** from the Start menu
2. Create your Linux username and password
3. Wait for the initial setup to complete

### Step 3: Install Nerd Fonts (for terminal icons)

Oh My Posh prompt and CLI tools use icons that require a Nerd Font. Install on **Windows**:

```powershell
winget install DEVCOM.JetBrainsMonoNerdFont
```

Then configure Windows Terminal to use it:
1. Open Windows Terminal → Settings (`Ctrl+,`)
2. Select your **Ubuntu** profile in the left sidebar
3. Click **Appearance**
4. Set **Font face** to `JetBrainsMono Nerd Font`
5. Click **Save**
6. **Close and reopen Windows Terminal** (required for the font to take effect)

> **Important:** If you skip this step, prompt icons will show as boxes or missing characters.

### Step 4: Install VS Code with WSL Extension

Install VS Code on Windows:

```powershell
winget install Microsoft.VisualStudioCode
```

Then install the required extensions:
1. [WSL extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)
2. [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=github.copilot) (recommended)

---

## Quick Start

Once prerequisites are complete, open **Windows Terminal** → **Ubuntu** and run:

```bash
wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash
```

That's it! The installer will:
1. Install all CLI tools for Azure and cloud-native development
2. Configure Docker CE to run natively in WSL2 (no Docker Desktop needed)
3. Set up Zsh with Oh My Posh prompt (1_shell theme) and productivity aliases
4. Configure GitHub CLI with Copilot integration

---

## What You Get

| Category | Tools |
|----------|-------|
| **Shell** | Zsh + [Oh My Posh](https://ohmyposh.dev) prompt (1_shell theme) + Nerd Fonts support |
| **Editor** | Neovim (VS Code recommended on Windows side with WSL extension) |
| **Cloud** | Azure CLI, azd, Bicep, Terraform, OpenTofu, PowerShell 7 |
| **Kubernetes** | kubectl, Helm, k9s |
| **Containers** | Docker CE (WSL2 native), lazydocker, Dev Containers support |
| **Git** | GitHub CLI, lazygit |
| **AI** | GitHub Copilot CLI (`gh copilot suggest`) |
| **CLI Utils** | bat, eza, fzf, ripgrep, zoxide, btop, fastfetch, jq, yq |

---

## Docker CE in WSL2

Kodra WSL configures Docker CE to run natively in WSL2—no Docker Desktop needed. It's free for all use cases, uses fewer resources, and Docker Desktop requires Windows 11.

### Docker Configuration

After installation, Docker will be automatically configured with:

```bash
# Docker daemon starts automatically with WSL
# Your user is added to the docker group
# No sudo required for docker commands

docker run hello-world  # Test it works!
```

### Docker Tips for WSL2

```bash
# Check Docker status
docker info

# If Docker isn't running, start it manually
sudo service docker start

# Enable Docker to start automatically (already configured by Kodra)
# This is handled via /etc/wsl.conf
```

---

## VS Code Integration

For the best experience, use **VS Code on Windows** with the WSL extension:

1. Install [VS Code](https://code.visualstudio.com/) on Windows
2. Install the [WSL extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)
3. Open projects from WSL: `code .` (from your WSL terminal)

### Recommended VS Code Extensions

Install these on the WSL side for optimal performance:

```bash
# Run from WSL terminal
code --install-extension ms-azuretools.vscode-azurefunctions
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension github.copilot
code --install-extension github.copilot-chat
code --install-extension ms-vscode.azure-account
code --install-extension hashicorp.terraform
code --install-extension redhat.vscode-yaml
code --install-extension eamodio.gitlens
```

---

## Commands

```bash
kodra doctor      # Check system health and WSL integration
kodra update      # Update all tools
kodra fetch       # Show system info (fastfetch)
kodra setup       # Re-run first-time setup (GitHub, Azure login)
```

---

## Windows Terminal Configuration

For the best terminal experience, add this to your Windows Terminal `settings.json`:

```json
{
    "profiles": {
        "list": [
            {
                "guid": "{your-ubuntu-guid}",
                "name": "Kodra WSL",
                "source": "Windows.Terminal.Wsl",
                "startingDirectory": "//wsl$/Ubuntu-24.04/home/YOUR_USERNAME",
                "fontFace": "JetBrainsMono Nerd Font",
                "fontSize": 12,
                "colorScheme": "Tokyo Night"
            }
        ]
    },
    "schemes": [
        {
            "name": "Tokyo Night",
            "background": "#1A1B26",
            "foreground": "#C0CAF5",
            "black": "#15161E",
            "red": "#F7768E",
            "green": "#9ECE6A",
            "yellow": "#E0AF68",
            "blue": "#7AA2F7",
            "purple": "#BB9AF7",
            "cyan": "#7DCFFF",
            "white": "#A9B1D6",
            "brightBlack": "#414868",
            "brightRed": "#F7768E",
            "brightGreen": "#9ECE6A",
            "brightYellow": "#E0AF68",
            "brightBlue": "#7AA2F7",
            "brightPurple": "#BB9AF7",
            "brightCyan": "#7DCFFF",
            "brightWhite": "#C0CAF5"
        }
    ]
}
```

---

## WSL2 Performance Tips

### 1. Store Projects in WSL Filesystem

For best performance, keep your code in the Linux filesystem:

```bash
# Good - native Linux performance
~/projects/my-app

# Bad - slow cross-filesystem access
/mnt/c/Users/you/projects/my-app
```

### 2. Configure WSL Memory (Optional)

Create/edit `%USERPROFILE%\.wslconfig` on Windows:

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
```

### 3. Disable Windows Defender for WSL Paths

Add WSL paths to Windows Defender exclusions for better I/O performance:
- `%USERPROFILE%\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu*`
- `\\wsl$\Ubuntu-24.04`

---

## Testing via Azure VM

You can test Kodra WSL installation by creating an Azure VM running Ubuntu that simulates a WSL environment. This is useful for CI/CD validation and testing the installer without a Windows machine.

### Create Test VM

```bash
# Create resource group
az group create --name kodra-wsl-test --location eastus

# Create Ubuntu 24.04 VM
az vm create \
    --resource-group kodra-wsl-test \
    --name kodra-test-vm \
    --image Ubuntu2404 \
    --size Standard_D2s_v3 \
    --admin-username kodra \
    --generate-ssh-keys

# Get public IP
az vm show -d -g kodra-wsl-test -n kodra-test-vm --query publicIps -o tsv
```

### Run Tests

```bash
# SSH into the VM
ssh kodra@<public-ip>

# Run the installer
wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash

# Run health check
kodra doctor
```

### Cleanup

```bash
az group delete --name kodra-wsl-test --yes
```

See [docs/AZURE-VM-TESTING.md](docs/AZURE-VM-TESTING.md) for detailed testing procedures.

---

## Customization

```bash
# Skip specific tools
KODRA_SKIP="terraform,helm" ./install.sh

# Debug mode (continue on errors, show summary)
./install.sh --debug
```

### Shell Customization

Your shell configuration is in `~/.kodra/`:

| File | Purpose |
|------|---------|
| `~/.kodra/configs/shell/kodra.sh` | Shell aliases and functions |
| `~/.config/oh-my-posh/themes/1_shell.omp.json` | Oh My Posh prompt theme |
| `~/.config/oh-my-posh/themes/kodra.omp.json` | Custom Kodra theme (Azure/K8s aware) |

---

## Uninstall

```bash
# Interactive uninstall
wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash

# Or directly
bash ~/.kodra/uninstall.sh
```

---

## Troubleshooting

### Prompt Icons Show as Boxes/Missing Characters

Windows Terminal is not using a Nerd Font:

1. Install the font: `winget install DEVCOM.JetBrainsMonoNerdFont`
2. Configure Windows Terminal:
   - Settings (`Ctrl+,`) → Ubuntu profile → Appearance
   - Set **Font face** to `JetBrainsMono Nerd Font`
3. **Close and reopen Windows Terminal**

### Oh My Posh Not Loading

If you see a plain prompt instead of Oh My Posh:

```bash
# Check if installed
oh-my-posh --version

# Reload your shell config
source ~/.zshrc

# Or re-run the installer
wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash
```

### More Help

See [docs/WSL-SETUP.md](docs/WSL-SETUP.md) for detailed troubleshooting.

---

## Compatibility

### Network
- **IPv4/IPv6:** All installation scripts work with both IPv4 and IPv6 networks
- **Proxy:** Set `http_proxy` and `https_proxy` environment variables before running the installer

### WSL Requirements
- **WSL2** required (WSL1 not supported for Docker)
- **Ubuntu 24.04** recommended (22.04 works but not officially tested)
- **Systemd** enabled (configured automatically by installer)

### No GUI Required
Kodra WSL is 100% CLI-based. No flatpak, snap store, or GUI installers needed. This keeps:
- Lower disk usage (~2GB vs 5GB+ for desktop environments)
- Faster installation
- Better compatibility with CI/CD environments

---

## Relationship to Kodra Desktop

Kodra WSL shares the same tool selection philosophy as [Kodra Desktop](https://github.com/codetocloudorg/kodra), but optimized for the WSL environment:

- **Shared:** Azure tooling, Git tools, CLI utilities, AI assistance
- **WSL-specific:** Docker CE configuration for WSL2, Windows Terminal integration
- **Desktop-only:** GNOME theming, Ghostty terminal, window tiling, ULauncher

If you're on a native Ubuntu machine, use [Kodra Desktop](https://github.com/codetocloudorg/kodra) instead for the full experience including the beautiful themed desktop.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on reporting issues, suggesting features, and submitting pull requests.

## License

Kodra WSL is released under the [MIT License](LICENSE).

---

<div align="center">

[![Discord](https://img.shields.io/badge/Discord-Join_Us-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/vwfwq2EpXJ)
[![GitHub](https://img.shields.io/badge/GitHub-codetocloudorg-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codetocloudorg)

**[kodra.wsl.codetocloud.io](https://kodra.wsl.codetocloud.io)**

*A WSL variant of [Kodra](https://kodra.codetocloud.io) • Developed by [Code To Cloud](https://www.codetocloud.io)*

</div>
