# Contributing to Kodra WSL

Thank you for your interest in contributing to Kodra WSL! This document provides guidelines for contributing.

## Code of Conduct

Be respectful and constructive. We welcome contributors of all skill levels.

## How to Contribute

### Reporting Issues

1. Check if the issue already exists in [GitHub Issues](https://github.com/codetocloudorg/kodra-wsl/issues)
2. If not, create a new issue with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - Your environment (Windows version, WSL version, Ubuntu version)
   - Output of `kodra doctor`

### Suggesting Features

Open a GitHub issue with the `enhancement` label. Include:
- What problem does this solve?
- How should it work?
- Any alternatives you've considered

### Pull Requests

1. **Fork** the repository
2. **Create a branch** for your feature: `git checkout -b feature/my-feature`
3. **Test your changes** on a fresh WSL installation or Azure VM
4. **Commit** with clear messages: `git commit -m "Add: new feature description"`
5. **Push** to your fork: `git push origin feature/my-feature`
6. **Open a PR** against `main`

## Development Setup

### Local Testing

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/kodra-wsl.git
cd kodra-wsl

# Make scripts executable
chmod +x boot.sh install.sh bin/kodra

# Test specific installers
export KODRA_DIR=$(pwd)
bash install/cloud/azure-cli.sh
```

### Testing on Azure VM

```bash
# Create test VM
RG="kodra-test-$(date +%s)"
az group create -n $RG -l eastus
az vm create -g $RG -n test --image Ubuntu2404 --generate-ssh-keys

# Copy and test
scp -r . azureuser@<IP>:~/.kodra
ssh azureuser@<IP> "~/.kodra/install.sh"
```

## Code Style

### Shell Scripts

- Use `#!/usr/bin/env bash`
- Use `set -e` for critical scripts
- Quote variables: `"$var"` not `$var`
- Use `[[ ]]` for conditionals
- Add comments for non-obvious code
- Follow existing naming conventions

### Installers

Each tool installer in `install/` should:

1. Source utility functions
2. Check if already installed
3. Install the tool
4. Verify installation
5. Show success/failure

Example:

```bash
#!/usr/bin/env bash
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Tool Name"

if command_exists tool; then
    version=$(tool --version 2>/dev/null | head -1)
    show_installed "Tool ($version)"
    exit 0
fi

# Installation logic here

if command_exists tool; then
    version=$(tool --version 2>/dev/null | head -1)
    show_installed "Tool ($version)"
else
    show_warn "Tool installation failed"
fi
```

## Adding New Tools

1. Create installer script in appropriate `install/` subdirectory
2. Add to `install.sh` in the correct section
3. Add check to `bin/kodra-sub/doctor.sh`
4. Update `README.md` tool list
5. Update `index.html` if it's a major tool
6. Test on fresh WSL/Ubuntu installation

## Commit Messages

Use conventional commits:

- `Add:` New feature
- `Fix:` Bug fix
- `Update:` Update existing feature
- `Remove:` Remove feature
- `Docs:` Documentation only
- `Refactor:` Code refactoring

## Questions?

- Open a [GitHub Discussion](https://github.com/codetocloudorg/kodra-wsl/discussions)
- Join our [Discord](https://discord.gg/vwfwq2EpXJ)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
