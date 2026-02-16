# Windows Integration Guide

Getting the most out of Kodra WSL by integrating with your Windows environment.

## Windows Terminal Configuration

### Set Ubuntu as Default Profile

1. Open Windows Terminal → Settings (`Ctrl+,`)
2. Under **Startup**, set **Default profile** to Ubuntu
3. Set **Default terminal application** to Windows Terminal

### Recommended Profile Settings

Add to your Windows Terminal `settings.json` (Ctrl+Shift+, to open JSON):

```json
{
    "guid": "{your-ubuntu-guid}",
    "name": "Kodra WSL",
    "source": "Windows.Terminal.Wsl",
    "startingDirectory": "//wsl$/Ubuntu-24.04/home/YOUR_USERNAME",
    "fontFace": "JetBrainsMono Nerd Font",
    "fontSize": 12,
    "colorScheme": "Tokyo Night",
    "padding": "8",
    "cursorShape": "bar",
    "antialiasingMode": "cleartype"
}
```

### Keyboard Shortcuts

Add useful shortcuts to Windows Terminal:

```json
{
    "actions": [
        { "command": { "action": "splitPane", "split": "horizontal" }, "keys": "alt+shift+-" },
        { "command": { "action": "splitPane", "split": "vertical" }, "keys": "alt+shift+=" },
        { "command": { "action": "newTab", "profile": "Ubuntu-24.04" }, "keys": "ctrl+shift+t" }
    ]
}
```

---

## VS Code WSL Extension

### Setup

1. Install VS Code on Windows: `winget install Microsoft.VisualStudioCode`
2. Install the [WSL extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)
3. From WSL terminal, open any folder: `code .`

### Recommended Extensions (Install in WSL)

```bash
# From WSL terminal
code --install-extension ms-azuretools.vscode-azurefunctions
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension github.copilot
code --install-extension github.copilot-chat
code --install-extension ms-vscode.azure-account
code --install-extension hashicorp.terraform
```

### Settings for WSL

Add to VS Code `settings.json`:

```json
{
    "terminal.integrated.defaultProfile.linux": "bash",
    "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font",
    "remote.WSL.fileWatcher.polling": false,
    "files.watcherExclude": {
        "**/node_modules/**": true,
        "**/.git/objects/**": true
    }
}
```

---

## PowerToys Integration

[PowerToys](https://github.com/microsoft/PowerToys) enhances the Windows experience alongside WSL.

### Install

```powershell
winget install Microsoft.PowerToys
```

### Useful PowerToys for WSL Developers

| Tool | Use Case |
|------|----------|
| **FancyZones** | Window tiling for terminal + VS Code side-by-side |
| **PowerToys Run** | Quick launch WSL terminal (Alt+Space) |
| **Color Picker** | Pick colors for terminal themes |
| **File Explorer Add-ons** | Preview YAML/JSON in File Explorer |

---

## File System Best Practices

### Where to Store Projects

```bash
# GOOD — Native WSL filesystem (fast)
~/projects/my-app
~/dev/my-service

# BAD — Mounted Windows drive (slow for builds, git, docker)
/mnt/c/Users/you/projects/my-app
/mnt/d/code/my-service
```

### Accessing WSL Files from Windows

In Windows File Explorer, type in the address bar:
```
\\wsl$\Ubuntu-24.04
```

Or use the shortcut:
```
\\wsl.localhost\Ubuntu-24.04\home\YOUR_USERNAME
```

### Accessing Windows Files from WSL

Windows drives are mounted under `/mnt/`:
```bash
ls /mnt/c/Users/  # C: drive
ls /mnt/d/        # D: drive
```

### Clipboard Sharing

Copy/paste works automatically between Windows and WSL in Windows Terminal:
- **Copy**: Select text (auto-copy) or `Ctrl+Shift+C`
- **Paste**: `Ctrl+Shift+V` or right-click

---

## Performance Tuning

### WSL Memory Configuration

Create or edit `%USERPROFILE%\.wslconfig` on Windows:

```ini
[wsl2]
memory=8GB       # Limit WSL memory (default: 50% of system RAM)
processors=4     # Limit CPU cores
swap=2GB         # Swap file size
localhostForwarding=true  # Access WSL services from Windows
```

After editing, restart WSL:
```powershell
wsl --shutdown
```

### Windows Defender Exclusions

Add WSL paths to reduce filesystem scanning overhead:

1. Open Windows Security → Virus & threat protection → Manage settings
2. Scroll to Exclusions → Add or remove exclusions
3. Add folder exclusions:
   - `%USERPROFILE%\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu*`
   - `%LOCALAPPDATA%\Docker`

### Disable Indexing for WSL Paths

Windows Search indexing can slow WSL I/O:
1. Right-click WSL mount in File Explorer → Properties
2. Uncheck "Allow files to have contents indexed"

---

## Windows 11 vs Windows 10 Differences

| Feature | Windows 10 | Windows 11 |
|---------|-----------|------------|
| WSL2 Support | ✅ (v2004+) | ✅ |
| WSLg (GUI apps) | ❌ | ✅ |
| systemd in WSL | ❌ | ✅ |
| Windows Terminal | Install separately | Pre-installed |
| Default WSL version | WSL1 (must set WSL2) | WSL2 |
| `wsl --install` simplified | Limited | ✅ Full |

### Windows 10 Extra Steps

If on Windows 10, you may need to:
1. Manually enable WSL2 (see [WSL-SETUP.md](WSL-SETUP.md))
2. Install Windows Terminal from the Microsoft Store
3. Ensure you're on version 2004 or later

---

## Networking

### Access WSL Services from Windows

Services running in WSL are accessible on localhost:
```bash
# In WSL
python -m http.server 8080

# In Windows browser
# http://localhost:8080 ← just works
```

### Access WSL from Other Machines

By default, WSL services are only accessible from the Windows host. To expose externally:

```powershell
# In PowerShell (Admin)
netsh interface portproxy add v4tov4 listenport=8080 listenaddress=0.0.0.0 connectport=8080 connectaddress=$(wsl hostname -I | ForEach-Object { $_.Trim() })
```

### SSH into WSL

```bash
# In WSL
sudo apt install openssh-server
sudo service ssh start

# From another machine
ssh your-username@your-windows-ip
```
