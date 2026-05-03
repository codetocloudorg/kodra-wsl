# Installation Guide

Detailed instructions for installing Kodra WSL on your Windows 11 machine.

---

## Prerequisites

Before you begin, make sure you have:

| Requirement | Details |
|-------------|---------|
| **Windows 11** | Windows 10 is not supported |
| **WSL2 enabled** | `wsl --install` from PowerShell (admin) |
| **Ubuntu 24.04** | Install from the [Microsoft Store](https://apps.microsoft.com/detail/9nz3klhxdjp5) |
| **Internet connection** | Required for downloading tools |
| **~5 GB disk space** | For all 25+ tools |

### Enabling WSL2

If you haven't already enabled WSL2, open PowerShell as Administrator and run:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart your computer when prompted, then open Ubuntu from the Start menu to complete initial setup.

---

## Quick Install

Open your WSL2 Ubuntu terminal and run:

```bash
curl -fsSL https://kodra.wsl.codetocloud.io/boot.sh | bash
```

Or with `wget`:

```bash
wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash
```

That's it. Kodra will clone the repository, detect your environment, and install everything automatically. The full process takes approximately 10 minutes on a typical connection.

---

## Manual Install

If you prefer to inspect the code before running it:

```bash
# 1. Clone the repository
git clone https://github.com/codetocloudorg/kodra-wsl.git ~/.kodra

# 2. Run the installer
cd ~/.kodra
bash install.sh
```

### Debug Mode

If you encounter issues, run in debug mode. This logs failures but continues the installation instead of stopping on the first error:

```bash
bash install.sh --debug
```

The full installation log is saved to a timestamped file in `/tmp/kodra-wsl-install-*.log`.

---

## Post-Install Steps

After installation completes:

### 1. Install a Nerd Font on Windows

Kodra installs JetBrains Mono Nerd Font inside WSL, but Windows Terminal needs the font installed on the Windows side too. Open PowerShell and run:

```powershell
winget install DEVCOM.JetBrainsMonoNerdFont
```

Then configure Windows Terminal:
- Open **Settings → Profiles → Ubuntu → Appearance**
- Set **Font face** to `JetBrainsMono Nerd Font`

### 2. Reload Your Shell

```bash
source ~/.bashrc
```

### 3. Verify the Installation

```bash
kodra doctor
```

This runs a full diagnostic check on every installed tool and reports its status.

---

## Interactive vs Non-Interactive Mode

### Interactive Mode (default)

When you run `install.sh` from a terminal with a TTY, Kodra presents a multi-select menu where you can choose which tool groups to install:

- Shell & Terminal (Oh My Posh, Nerd Fonts)
- CLI Tools (fzf, bat, eza, zoxide, btop, etc.)
- Git Tools (GitHub CLI, lazygit, Copilot CLI)
- Azure & Cloud (Azure CLI, azd, Bicep, Terraform, OpenTofu)
- Containers (Docker CE, lazydocker)
- Kubernetes (kubectl, Helm, k9s)

### Non-Interactive Mode

When piped through `curl` or `wget`, or when the `KODRA_SKIP_PROMPTS` environment variable is set, Kodra installs everything without prompting:

```bash
KODRA_SKIP_PROMPTS=true bash install.sh
```

---

## Custom Installation

### Skip Specific Tools

Use the `KODRA_SKIP` environment variable to exclude tools:

```bash
KODRA_SKIP="terraform,helm" bash install.sh
```

### Re-run the Installer

Running the installer again is safe — it will update existing tools and install any missing ones:

```bash
cd ~/.kodra
bash install.sh
```

Or re-run the bootstrap:

```bash
curl -fsSL https://kodra.wsl.codetocloud.io/boot.sh | bash
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KODRA_DIR` | `~/.kodra` | Installation directory for Kodra |
| `KODRA_SKIP_PROMPTS` | `false` | Skip all interactive prompts |
| `KODRA_DEBUG` | `false` | Enable debug mode (log errors, continue) |
| `KODRA_SKIP` | _(empty)_ | Comma-separated list of tools to skip |

Example using all variables:

```bash
KODRA_DIR="$HOME/.kodra" \
KODRA_SKIP_PROMPTS=true \
KODRA_DEBUG=true \
KODRA_SKIP="terraform,opentofu" \
bash install.sh
```

---

## Verifying Installation

Run `kodra doctor` to check that everything is working:

```
$ kodra doctor

  Kodra WSL v0.7.1 — System Health Check

  ╭──────────────────────────────────────────────────╮
  │  Tool              Status     Version             │
  ├──────────────────────────────────────────────────┤
  │  Azure CLI         ✔ ok       2.67.0              │
  │  azd               ✔ ok       1.11.0              │
  │  Bicep             ✔ ok       0.32.4              │
  │  Terraform         ✔ ok       1.10.3              │
  │  Docker CE         ✔ ok       27.4.1              │
  │  kubectl           ✔ ok       1.32.0              │
  │  Helm              ✔ ok       3.16.4              │
  │  GitHub CLI        ✔ ok       2.63.0              │
  │  Copilot CLI       ✔ ok       1.0.5               │
  │  Oh My Posh        ✔ ok       24.15.0             │
  │  fzf               ✔ ok       0.57.0              │
  │  bat               ✔ ok       0.24.0              │
  │  eza               ✔ ok       0.20.14             │
  │  zoxide            ✔ ok       0.9.6               │
  │  ...               ...        ...                 │
  ╰──────────────────────────────────────────────────╯

  25/25 tools installed ✔
```

---

## Troubleshooting

### "Permission denied" during install

Make sure you have sudo access:

```bash
sudo -v && curl -fsSL https://kodra.wsl.codetocloud.io/boot.sh | bash
```

### Icons show as boxes in Windows Terminal

You need a Nerd Font installed on the Windows side and configured in Windows Terminal. See the [Post-Install Steps](#1-install-a-nerd-font-on-windows) above.

### Docker isn't running after install

Docker CE requires systemd. Restart your WSL instance:

```powershell
# From PowerShell
wsl --shutdown
wsl
```

Then verify:

```bash
docker info
```

### Oh My Posh prompt not appearing

Reload your shell configuration:

```bash
source ~/.bashrc
oh-my-posh --version
```

### Installer fails partway through

Re-run with debug mode to see which step failed:

```bash
cd ~/.kodra
bash install.sh --debug
```

Check the log file printed at the end of the error message.

### WSL1 instead of WSL2

Upgrade your WSL distribution:

```powershell
wsl --set-version Ubuntu-24.04 2
```

For more troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) and [WSL-SETUP.md](WSL-SETUP.md).

---

## Uninstalling

To remove Kodra WSL, run:

```bash
bash ~/.kodra/uninstall.sh
```

This removes Kodra configurations but leaves installed tools (Docker, Azure CLI, etc.) in place. See [UNINSTALL.md](UNINSTALL.md) for a complete removal guide.
