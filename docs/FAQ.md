# Frequently Asked Questions

## General

### Is Kodra WSL free?

Yes, Kodra WSL is 100% free and open source under the [MIT License](../LICENSE). All tools installed by Kodra are also free, including Docker CE which has no licensing restrictions.

### What is Kodra WSL?

Kodra WSL is a one-command installer that sets up a complete Azure developer environment inside WSL2 (Windows Subsystem for Linux). It installs 25+ CLI tools including Docker CE, Azure CLI, GitHub Copilot CLI, Kubernetes tools, and a beautiful Oh My Posh terminal prompt.

### Who is Kodra WSL for?

Windows developers who want:
- A complete cloud-native development environment in WSL2
- Docker without Docker Desktop licensing costs
- Azure and GitHub tooling configured automatically
- A beautiful, productive terminal experience

---

## Docker

### Do I need Docker Desktop?

**No.** Kodra WSL installs Docker CE (Community Edition) directly in WSL2. This is a free, open-source alternative to Docker Desktop with no licensing restrictions.

### How is Docker CE different from Docker Desktop?

Docker CE is the open-source Docker engine. Docker Desktop adds a proprietary GUI layer and requires paid licenses for companies with 250+ employees or $10M+ annual revenue. Docker CE in WSL2 gives you the same Docker engine for free.

See [DOCKER_CE_VS_DESKTOP.md](DOCKER_CE_VS_DESKTOP.md) for a detailed comparison.

### Will my Docker Compose files work?

Yes. Docker Compose v2 is installed as a CLI plugin. Use `docker compose` (space, not hyphen) for all compose commands.

### Do VS Code Dev Containers work?

Yes. VS Code automatically detects Docker running in WSL2. Dev Containers work without any extra configuration.

### Can I switch from Docker Desktop to Docker CE?

Yes. Uninstall Docker Desktop first, then install Kodra WSL. See the migration guide in [DOCKER_CE_VS_DESKTOP.md](DOCKER_CE_VS_DESKTOP.md).

---

## Windows & WSL

### Does it work on Windows 10?

WSL2 is available on Windows 10 version 2004 and later. Kodra WSL is primarily tested on Windows 11 but should work on Windows 10 with WSL2 enabled.

### Does it work on Windows 11?

Yes, Windows 11 is the recommended and fully tested platform.

### What Ubuntu version do I need?

Ubuntu 24.04 LTS is recommended. Ubuntu 22.04 works but is not officially tested.

### Does it modify my Windows installation?

No. Everything is installed inside WSL2. Your Windows system is not modified. The only Windows-side recommendations are installing Windows Terminal and a Nerd Font.

### Can I use PowerShell instead of bash?

Kodra WSL configures bash inside WSL2. You use PowerShell on the Windows side for WSL management, but your development work happens in the WSL2 bash terminal.

---

## Tools

### What tools are included?

| Category | Tools |
|----------|-------|
| Shell | Oh My Posh, Nerd Fonts |
| Cloud | Azure CLI, azd, Bicep, Terraform, OpenTofu, PowerShell 7 |
| Kubernetes | kubectl, Helm, k9s |
| Containers | Docker CE, lazydocker |
| Git | GitHub CLI, lazygit |
| AI | Copilot CLI |
| CLI Utils | bat, eza, fzf, ripgrep, zoxide, btop, fastfetch, jq, yq |

### Can I skip certain tools?

Yes. Use the `KODRA_SKIP` environment variable:

```bash
KODRA_SKIP="terraform,helm" ./install.sh
```

### How do I update tools?

Run `kodra update` to update all installed tools to their latest versions.

---

## Kodra WSL vs Kodra Desktop

### What's the difference?

| | Kodra WSL | Kodra Desktop |
|---|---|---|
| Platform | WSL2 on Windows | Native Ubuntu |
| Desktop | None (CLI only) | GNOME with theming |
| Terminal | Windows Terminal | Ghostty |
| Use case | Windows developers | Ubuntu desktop users |

### Can I use both?

Yes — Kodra WSL on your Windows machine and Kodra Desktop on a native Ubuntu machine. They share the same tool philosophy.

---

## Licensing & Usage

### Can I use this for commercial projects?

Yes. The MIT License permits commercial use with no restrictions.

### Can my company use this?

Yes. Unlike Docker Desktop, there are no organizational licensing requirements. Docker CE and all tools are free for any organization size.

### Can I modify Kodra WSL for my team?

Yes. Fork the repo, customize the tool list, and distribute internally. MIT License allows this.

---

## Troubleshooting

### Icons show as boxes in the terminal

Install a Nerd Font and configure Windows Terminal to use it:

```powershell
winget install DEVCOM.JetBrainsMonoNerdFont
```

Then set `JetBrainsMono Nerd Font` as the font in Windows Terminal settings.

### Docker isn't running

```bash
# Start Docker manually
sudo service docker start

# Check status
docker info
```

### Oh My Posh prompt not showing

```bash
# Reload shell config
source ~/.bashrc

# Check if installed
oh-my-posh --version
```

See [WSL-SETUP.md](WSL-SETUP.md) for more troubleshooting steps.
