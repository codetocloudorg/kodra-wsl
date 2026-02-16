# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.6.x   | :white_check_mark: |
| 0.5.x   | :white_check_mark: |
| < 0.5   | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in Kodra WSL, please report it responsibly.

### How to Report

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, please:

1. **Email**: Send details to security@codetocloud.io
2. **Discord**: DM a maintainer on our [Discord server](https://discord.gg/vwfwq2EpXJ)

### What to Include

Please include the following information:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Any suggested fixes (optional)

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Resolution Target**: Within 30 days for critical issues

### Security Best Practices for Users

When using Kodra WSL:

1. **Review scripts before running**: Always inspect `boot.sh` and installation scripts before execution
2. **Keep WSL updated**: Run `wsl --update` regularly
3. **Update Kodra tools**: Run `kodra update` to get the latest tool versions
4. **Secure your credentials**: 
   - Don't commit Azure credentials to repos
   - Use `az login` for authentication
   - Store secrets in Azure Key Vault

### Third-Party Tools

Kodra WSL installs several third-party tools. Security updates for these tools are managed by their respective maintainers:

- **Docker CE**: [Docker Security](https://docs.docker.com/engine/security/)
- **Azure CLI**: [Microsoft Security Updates](https://docs.microsoft.com/security-updates/)
- **GitHub CLI**: [GitHub Security](https://github.com/security)
- **Terraform/OpenTofu**: [HashiCorp Security](https://www.hashicorp.com/security)

We recommend running `kodra update` regularly to get the latest versions.

### WSL-Specific Security

- WSL2 runs in a lightweight VM, providing isolation from Windows
- Docker CE runs within WSL2, not as a Windows service
- Firewall rules should be configured for WSL network access if needed

## Acknowledgments

We appreciate responsible security researchers who help keep Kodra WSL safe. Contributors who report valid security issues will be acknowledged (with permission) in our release notes.
