# WSL Setup Guide

This guide covers setting up WSL2 on Windows for use with Kodra WSL.

## Prerequisites

- Windows 10 version 2004+ (Build 19041+) or Windows 11
- Administrator access
- At least 8GB RAM recommended
- ~10GB free disk space

## Installing WSL2

### Option 1: Quick Install (Recommended)

Open PowerShell as Administrator and run:

```powershell
wsl --install -d Ubuntu-24.04
```

This command will:
1. Enable the WSL feature
2. Enable Virtual Machine Platform
3. Download and install the Linux kernel
4. Set WSL2 as default
5. Download and install Ubuntu 24.04

**Restart your computer** when prompted.

### Option 2: Manual Install

If the quick install doesn't work, follow these steps:

1. **Enable WSL Feature**
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   ```

2. **Enable Virtual Machine Platform**
   ```powershell
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

3. **Restart your computer**

4. **Download and install the Linux kernel update**
   - Download from: https://aka.ms/wsl2kernel
   - Run the installer

5. **Set WSL2 as default**
   ```powershell
   wsl --set-default-version 2
   ```

6. **Install Ubuntu 24.04**
   ```powershell
   wsl --install -d Ubuntu-24.04
   ```

## First-Time Ubuntu Setup

After installation, Ubuntu will launch automatically. You'll be prompted to:

1. **Create a username** - This is your Linux username (can be different from Windows)
2. **Create a password** - This is your Linux password (used for `sudo`)

```bash
Enter new UNIX username: yourname
New password: ********
Retype new password: ********
```

## Verify WSL2 Installation

Check that WSL2 is running correctly:

```powershell
# In PowerShell
wsl --list --verbose
```

You should see:
```
  NAME            STATE           VERSION
* Ubuntu-24.04    Running         2
```

**Important:** VERSION should be `2`. If it shows `1`, convert it:

```powershell
wsl --set-version Ubuntu-24.04 2
```

## Install Windows Terminal (Recommended)

Windows Terminal provides a much better experience than the default console.

### Option 1: Microsoft Store
Search for "Windows Terminal" in the Microsoft Store and install.

### Option 2: Winget
```powershell
winget install Microsoft.WindowsTerminal
```

### Option 3: Direct Download
https://github.com/microsoft/terminal/releases

## Configure Windows Terminal for Kodra

After installing Kodra WSL, add this profile to your Windows Terminal `settings.json`:

1. Open Windows Terminal
2. Press `Ctrl+,` to open settings
3. Click "Open JSON file" in the bottom left
4. Add this profile to the `profiles.list` array:

```json
{
    "guid": "{your-ubuntu-guid}",
    "name": "Kodra WSL",
    "source": "Windows.Terminal.Wsl",
    "startingDirectory": "//wsl$/Ubuntu-24.04/home/YOUR_USERNAME",
    "fontFace": "JetBrainsMono Nerd Font",
    "fontSize": 12,
    "colorScheme": "Tokyo Night",
    "icon": "🚀"
}
```

Add this color scheme to the `schemes` array:

```json
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
```

## Install Nerd Fonts on Windows

For the Starship prompt and icons to display correctly, install a Nerd Font:

1. Download JetBrains Mono Nerd Font:
   https://github.com/ryanoasis/nerd-fonts/releases/latest

2. Extract the zip file

3. Select all `.ttf` files, right-click, and choose "Install for all users"

4. Configure Windows Terminal to use the font (see configuration above)

## WSL Performance Optimization

### 1. Store Projects in WSL Filesystem

For best performance, always work within the Linux filesystem:

```bash
# Good - native performance
cd ~
mkdir projects
cd projects
git clone https://github.com/your/repo

# Bad - slow cross-filesystem access
cd /mnt/c/Users/you/projects
```

### 2. Configure WSL Resources

Create `%USERPROFILE%\.wslconfig` with:

```ini
[wsl2]
# Limit memory (adjust based on your system)
memory=8GB

# Limit processors
processors=4

# Swap space
swap=2GB

# Disable page reporting to free memory faster
pageReporting=false

# Enable nested virtualization (for Docker)
nestedVirtualization=true
```

After editing, restart WSL:
```powershell
wsl --shutdown
```

### 3. Exclude WSL from Windows Defender

Add these paths to Windows Defender exclusions for better I/O:

1. Open Windows Security
2. Virus & threat protection → Manage settings
3. Exclusions → Add or remove exclusions
4. Add these folder exclusions:
   - `%USERPROFILE%\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu*`
   - `%LOCALAPPDATA%\Packages\CanonicalGroupLimited.Ubuntu*`

Or via PowerShell (as Administrator):
```powershell
Add-MpPreference -ExclusionPath "$env:USERPROFILE\AppData\Local\Packages"
Add-MpPreference -ExclusionPath "\\wsl$"
```

### 4. Enable Systemd (for Docker auto-start)

Kodra WSL configures this automatically, but if needed manually:

Edit `/etc/wsl.conf` in WSL:
```bash
sudo nano /etc/wsl.conf
```

Add:
```ini
[boot]
systemd=true
```

Restart WSL:
```powershell
wsl --shutdown
```

## Networking in WSL2

### Accessing Windows from WSL
```bash
# Get Windows host IP
cat /etc/resolv.conf | grep nameserver | awk '{print $2}'
```

### Accessing WSL from Windows
WSL services are available at `localhost` on Windows. For example, a web server running on port 3000 in WSL is accessible at `http://localhost:3000` in Windows.

### Port Forwarding
If you need to access WSL from other machines on your network, use `netsh` in Windows:

```powershell
# Forward port 3000 (run as Administrator)
netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=localhost
```

## Troubleshooting

### WSL Won't Start
```powershell
# Restart WSL
wsl --shutdown
wsl

# If that fails, restart the LxssManager service
net stop LxssManager
net start LxssManager
```

### Memory Issues
WSL2 can consume a lot of memory. Configure limits in `.wslconfig` (see above).

To release memory without restarting:
```bash
# In WSL
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
```

### Slow File Access in /mnt/c
This is expected - working with Windows files from WSL is slow. Move your projects to the Linux filesystem (`~/projects`).

### Docker Not Starting
If Docker fails to start, check:
1. WSL2 is running (not WSL1)
2. Systemd is enabled (`systemctl status docker`)
3. Restart WSL with `wsl --shutdown`

### VS Code Can't Connect
If VS Code can't connect to WSL:
1. Reinstall the WSL extension
2. Clear VS Code server: `rm -rf ~/.vscode-server`
3. Restart VS Code

## Next Steps

Once WSL2 is set up, install Kodra WSL:

```bash
wget -qO- https://kodra-wsl.codetocloud.io/boot.sh | bash
```

Then verify your installation:
```bash
kodra doctor
```
