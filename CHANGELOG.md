# Changelog

All notable changes to Kodra WSL will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.0] - 2026-02-16

### Added
- Standalone Copilot CLI support (no longer requires GitHub CLI extension)
- New `kodra setup` command for re-running first-time configuration
- Azure VM testing documentation for CI/CD validation
- Improved Docker CE configuration with automatic startup via wsl.conf

### Changed
- Updated Oh My Posh to use 1_shell theme by default
- Improved installation progress indicators
- Better error handling in tool installers

### Fixed
- Docker service not starting automatically in some WSL configurations
- Font configuration guidance for Windows Terminal

## [0.5.0] - 2026-01-15

### Added
- Docker CE installation and configuration for WSL2
- lazydocker for Docker container management
- k9s for Kubernetes cluster visualization
- btop for system monitoring

### Changed
- Reorganized installer scripts into categories (cloud, containers, cli-tools)
- Improved `kodra doctor` health check output

### Fixed
- PATH configuration for newly installed tools
- Oh My Posh theme not loading on first shell launch

## [0.4.0] - 2025-12-01

### Added
- OpenTofu support alongside Terraform
- PowerShell 7 for Azure Bicep development
- Helm for Kubernetes package management
- Azure Developer CLI (azd) installation

### Changed
- Switched to JetBrainsMono Nerd Font as default
- Updated installation scripts to use latest tool versions

## [0.3.0] - 2025-10-15

### Added
- Bicep CLI for Azure infrastructure as code
- yq for YAML processing
- fastfetch for system information display
- Discord community integration

### Changed
- Improved first-run experience with guided Azure/GitHub login
- Better integration with VS Code WSL extension

## [0.2.0] - 2025-08-01

### Added
- GitHub CLI installation and configuration
- Copilot CLI (via GitHub CLI extension)
- lazygit for Git visualization
- fzf for fuzzy finding

### Changed
- Moved to dedicated kodra.wsl.codetocloud.io domain
- Improved installation error handling

## [0.1.0] - 2025-06-01

### Added
- Initial release of Kodra WSL
- Azure CLI installation
- Terraform installation
- kubectl installation
- Oh My Posh prompt configuration
- Basic shell aliases and functions
- One-command installer via boot.sh

[0.6.0]: https://github.com/codetocloudorg/kodra-wsl/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/codetocloudorg/kodra-wsl/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/codetocloudorg/kodra-wsl/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/codetocloudorg/kodra-wsl/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/codetocloudorg/kodra-wsl/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/codetocloudorg/kodra-wsl/releases/tag/v0.1.0
