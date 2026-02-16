# Roadmap

Future plans for Kodra WSL. This is a living document — priorities may shift based on community feedback.

## Current Version: 0.6.0

---

## Planned

### v0.7.0 — Developer Workflow
- [ ] `kodra init` — project scaffolding templates (Azure Functions, AKS, static web apps)
- [ ] Devcontainer.json templates for common Azure project types
- [ ] Auto-detect and configure `.wslconfig` for optimal performance
- [ ] Shell completions for all installed tools

### v0.8.0 — Team Features
- [ ] `kodra export` — export tool list and versions for team standardization
- [ ] `kodra import` — import team configuration from shared config
- [ ] Custom tool profiles (e.g., "azure-only", "full-stack", "data-engineering")
- [ ] Offline installation mode (pre-downloaded packages)

### v0.9.0 — Automation
- [ ] CI/CD GitHub Action for validating Kodra WSL installations
- [ ] Automated testing matrix (Windows 10/11, Ubuntu 22.04/24.04)
- [ ] Nightly build validation

### v1.0.0 — Stable Release
- [ ] Comprehensive test coverage
- [ ] Stable CLI API (`kodra` commands)
- [ ] Full documentation site
- [ ] Enterprise deployment guide

---

## Under Consideration
- Podman as alternative container runtime
- nix or homebrew as alternative package manager backend
- WSLg GUI app support (for tools like DBeaver)
- Ansible playbook for enterprise deployment
- Windows Package Manager (winget) integration for Windows-side prerequisites

---

## Completed
- [x] Docker CE installation and WSL2 configuration
- [x] Copilot CLI standalone support
- [x] Azure VM testing workflow
- [x] Oh My Posh with 1_shell theme
- [x] Uninstaller script
- [x] `kodra doctor` health check
- [x] `kodra update` tool updater

---

## How to Influence the Roadmap

1. **Vote on issues**: React with 👍 on [GitHub Issues](https://github.com/codetocloudorg/kodra-wsl/issues) you care about
2. **Request features**: Open a new issue with the `enhancement` label
3. **Discuss**: Join [Discord](https://discord.gg/vwfwq2EpXJ) to share your ideas
4. **Contribute**: See [CONTRIBUTING.md](../CONTRIBUTING.md) to submit PRs
