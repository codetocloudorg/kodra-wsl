# AGENTS.md — AI Coding Agent Guide for Kodra WSL

## Project Overview

Kodra WSL is a one-command Azure developer environment for WSL2. It transforms a fresh WSL2 Ubuntu install into a fully-configured cloud-native development workstation with 25+ tools — zero config required. Built and maintained by [Code To Cloud Inc.](https://www.codetocloud.io)

**Website**: [kodra.wsl.codetocloud.io](https://kodra.wsl.codetocloud.io)

Key focuses:
- Azure cloud development (CLI, azd, Bicep, Terraform, OpenTofu)
- Docker CE (no Docker Desktop license required), Kubernetes (kubectl, Helm, k9s)
- Modern terminal experience (Oh My Posh prompt, Nerd Fonts, fzf, zoxide, eza, bat)
- GitHub Copilot CLI for AI-powered terminal workflows
- WSL2-native setup (systemd via wsl.conf, Docker CE inside WSL)

---

## Shell Conventions

All scripts in this project **must** follow these conventions:

```bash
#!/usr/bin/env bash
set -e
```

- **`set -e`** — every script exits on first error. No silent failures.
- **`snake_case`** for function names: `install_docker`, `check_tool_version`
- **`UPPERCASE`** for global constants and environment variables: `KODRA_DIR`, `KODRA_VERSION`
- **`local`** for all variables inside functions — no leaking into global scope
- **`command -v`** to check if a command exists — **never** use `which`
- **Double-quote** all variable expansions: `"${KODRA_DIR}"`, not `$KODRA_DIR`
- Use `printf` over `echo` for portable output where formatting matters
- Source shared libraries with: `source "${KODRA_DIR}/lib/utils.sh"`

---

## File Organization

```
kodra-wsl/
├── bin/kodra                  # CLI dispatcher (entry point)
├── bin/kodra-sub/             # Subcommands
│   ├── doctor.sh              #   System health checks
│   ├── repair.sh              #   Interactive repair menu
│   ├── update.sh              #   Update all installed tools
│   └── first-run.sh           #   First-time setup wizard
├── install/                   # Tool installers by category
│   ├── cloud/                 #   azure-cli.sh, azd.sh, bicep.sh, terraform.sh, opentofu.sh,
│   │                          #   powershell.sh, kubectl.sh, helm.sh, k9s.sh
│   ├── containers/            #   docker-ce.sh, lazydocker.sh
│   ├── terminal/              #   oh-my-posh.sh, nerd-fonts.sh
│   └── cli-tools/             #   github-cli.sh, copilot-cli.sh, fzf.sh, lazygit.sh,
│                              #   zoxide.sh, eza.sh, bat.sh, btop.sh, fastfetch.sh,
│                              #   ripgrep.sh, yq.sh
├── lib/
│   ├── ui.sh                  # TUI components (spinners, colors, prompts)
│   └── utils.sh               # Shared utility functions
├── boot.sh                    # Bootstrap script (curl/wget entry point)
├── install.sh                 # Main installer orchestrator
├── uninstall.sh               # Clean uninstaller
├── index.html                 # Landing page
├── 404.html                   # Custom 404 page
├── sitemap.xml                # SEO sitemap
├── robots.txt                 # Crawler directives
├── manifest.json              # Web app manifest
├── llms.txt                   # LLM-readable project summary
├── llms-full.txt              # LLM-readable full documentation
├── AGENTS.md                  # This file — AI agent guide
├── SECURITY.md                # Security policy
├── CONTRIBUTING.md             # Contribution guidelines
├── CODE_OF_CONDUCT.md          # Community code of conduct
├── CHANGELOG.md               # Release history
├── VERSION                    # Current version number
└── assets/                    # Static assets (favicon, screenshots)
```

---

## WSL-Specific Considerations

Kodra WSL runs **exclusively inside WSL2 Ubuntu**. Key differences from a full desktop Linux setup:

- **No desktop environment** — there is no GUI, no display server, no desktop themes
- **systemd** is enabled via `/etc/wsl.conf` (`[boot] systemd=true`)
- **Docker CE** runs natively inside WSL2 — no Docker Desktop dependency
- **No Ghostty** — terminal emulator is Windows Terminal (managed by the user on Windows side)
- **No Starship** — prompt is Oh My Posh (configured in `.bashrc`/`.zshrc`)
- **No tmux** — not part of the WSL installation scope
- **No wallpapers or themes** — WSL has no graphical desktop
- **Fonts** are installed to `~/.local/share/fonts` for WSL-side apps; Windows Terminal fonts are a user concern

---

## Testing

### Syntax Check All Scripts

```bash
find . -name "*.sh" -exec bash -n {} \;
```

This validates every shell script for syntax errors without executing them.

### Health Check

```bash
kodra doctor
```

Runs the full diagnostic suite — checks every installed tool, verifies versions, and reports status.

### Manual Verification

```bash
# Check a specific installer runs cleanly
bash install/cloud/azure-cli.sh

# Verify the CLI dispatcher works
bin/kodra help
bin/kodra version
```

---

## What NOT to Do

| ❌ Don't | ✅ Do Instead |
|---|---|
| Use `sudo` inside installer scripts | Installers are run by `install.sh` which handles elevation |
| Hardcode paths like `/home/user/...` | Use `${HOME}`, `${KODRA_DIR}`, or relative paths |
| Use `eval` to run commands | Call commands directly or use arrays for complex args |
| Use `which` to check for commands | Use `command -v` |
| Add Ghostty configuration | WSL uses Windows Terminal — no Ghostty |
| Add Starship prompt config | WSL uses Oh My Posh |
| Add desktop themes or wallpapers | WSL has no desktop environment |
| Add tmux configuration | tmux is not in scope for WSL |
| Reference Cursor editor | Reference VS Code or generic editor |
| Skip `set -e` in scripts | Every script must have `set -e` |
| Use unquoted variables | Always double-quote: `"${var}"` |

---

## SEO — kodra.wsl.codetocloud.io

The landing page targets these search intents:

- "free Docker Desktop alternative for WSL2"
- "Azure developer tools WSL setup"
- "WSL2 development environment one command"
- "GitHub Copilot CLI WSL"
- "Docker CE WSL2 without Docker Desktop"
- "Kubernetes tools for WSL"

### SEO Files

| File | Purpose |
|---|---|
| `index.html` | Landing page with structured data, Open Graph, Twitter cards |
| `sitemap.xml` | XML sitemap for search engines |
| `robots.txt` | Crawler directives (allow all) |
| `manifest.json` | Web app manifest for PWA metadata |
| `llms.txt` | LLM-readable project summary |
| `llms-full.txt` | LLM-readable full documentation |
| `404.html` | Custom 404 page (branded, links back to home) |

When editing SEO content, ensure:
- Canonical URL is `https://kodra.wsl.codetocloud.io`
- Open Graph image points to `/assets/screenshots/social-preview.png`
- Structured data (`application/ld+json`) is valid JSON
- All internal links use relative paths or the canonical domain

---

## Version Bump Checklist

When releasing a new version of Kodra WSL:

1. **`VERSION`** — update the version number
2. **`CHANGELOG.md`** — add release notes under new version heading
3. **`index.html`** — update any version references in the landing page
4. **`llms.txt`** — update the `Version:` line
5. **`llms-full.txt`** — update version references
6. **`install.sh`** — update `KODRA_VERSION` if hardcoded
7. **`boot.sh`** — update version if referenced
8. **`sitemap.xml`** — update `<lastmod>` dates
9. **`lib/utils.sh`** — update version constant if defined there

Tag the release: `git tag -a v<version> -m "Release v<version>"`

---

## Adding a New Tool Installer

1. Create `install/<category>/<tool-name>.sh`
2. Follow the script template:
   ```bash
   #!/usr/bin/env bash
   set -e
   source "$(dirname "$0")/../../lib/utils.sh"

   install_<tool_name>() {
       local version="${1:-latest}"
       # Installation logic here
   }

   install_<tool_name>
   ```
3. Add the tool to `install.sh` orchestrator
4. Add a health check in `bin/kodra-sub/doctor.sh`
5. Add update logic in `bin/kodra-sub/update.sh`
6. Add repair logic in `bin/kodra-sub/repair.sh`
7. Update `llms.txt` and `llms-full.txt` tool lists
8. Update `README.md` tool count and table
