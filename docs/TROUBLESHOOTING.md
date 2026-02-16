# Troubleshooting

Common issues and solutions for Kodra WSL.

## Installation Issues

### Installer fails to download

**Symptom:** `wget` or `curl` fails when running the boot command.

**Solutions:**
1. Check internet connectivity: `ping google.com`
2. If behind a proxy, set environment variables first:
   ```bash
   export http_proxy="http://proxy:port"
   export https_proxy="http://proxy:port"
   wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash
   ```
3. Try with curl instead:
   ```bash
   curl -fsSL https://kodra.wsl.codetocloud.io/boot.sh | bash
   ```

### Permission denied errors

**Symptom:** `Permission denied` during installation.

**Solution:** The installer needs sudo access for package installation:
```bash
# Make sure your user has sudo
sudo whoami  # Should print: root
```

### Installer hangs at a particular tool

**Symptom:** Installation stops progressing.

**Solution:**
1. Press `Ctrl+C` to cancel
2. Re-run the installer — it will skip already installed tools
3. Or install the problematic tool individually:
   ```bash
   export KODRA_DIR=~/.kodra
   bash ~/.kodra/install/cloud/azure-cli.sh
   ```

---

## Docker Issues

### Docker daemon not running

**Symptom:** `Cannot connect to the Docker daemon`

**Solutions:**
```bash
# Start Docker
sudo service docker start

# Check if your user is in the docker group
groups | grep docker

# If not, add yourself (already done by Kodra, but just in case)
sudo usermod -aG docker $USER

# Restart WSL to apply group changes
# In PowerShell: wsl --shutdown
# Then reopen Ubuntu
```

### Docker starts but stops immediately

**Symptom:** Docker starts but `docker info` fails after a moment.

**Solution:** Check if iptables is configured correctly:
```bash
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo service docker restart
```

### Docker build is slow

**Solutions:**
1. Store your project in the WSL filesystem (not `/mnt/c/`):
   ```bash
   # Good
   ~/projects/my-app
   
   # Slow
   /mnt/c/Users/you/projects/my-app
   ```
2. Increase WSL memory in `%USERPROFILE%\.wslconfig`:
   ```ini
   [wsl2]
   memory=8GB
   processors=4
   ```

---

## Terminal Issues

### Icons show as boxes or question marks

**Symptom:** Prompt and tool icons display as `□` or `?`.

**Fix:**
1. Install the Nerd Font on Windows:
   ```powershell
   winget install DEVCOM.JetBrainsMonoNerdFont
   ```
2. Configure Windows Terminal:
   - Settings (`Ctrl+,`) → Ubuntu profile → Appearance
   - Set **Font face** to `JetBrainsMono Nerd Font`
3. **Close and reopen Windows Terminal entirely**

### Oh My Posh not loading

**Symptom:** Plain bash prompt instead of Oh My Posh.

**Solutions:**
```bash
# Check if installed
oh-my-posh --version

# Check if .bashrc sources kodra config
grep "kodra" ~/.bashrc

# Manually reload
source ~/.bashrc

# If still broken, re-run installer
wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash
```

### Colors look wrong

**Symptom:** Terminal colors don't match screenshots.

**Fix:** Use the Tokyo Night color scheme. Add to Windows Terminal `settings.json`:
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
    "white": "#A9B1D6"
}
```

---

## Azure CLI Issues

### `az login` fails in WSL

**Symptom:** Browser doesn't open for Azure login.

**Solutions:**
```bash
# Use device code flow (works reliably in WSL)
az login --use-device-code

# Or if you have a browser on Windows side
export BROWSER=wslview
az login
```

### Azure CLI not found after installation

**Solution:**
```bash
# Reload PATH
source ~/.bashrc

# Or check directly
/usr/bin/az --version
```

---

## VS Code Issues

### `code .` doesn't work

**Symptom:** Command not found when running `code .` in WSL.

**Solutions:**
1. Make sure VS Code is installed on Windows
2. Install the [WSL extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)
3. Open VS Code on Windows first, then try `code .` from WSL again
4. If still failing:
   ```bash
   export PATH="$PATH:/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin"
   code .
   ```

### Dev Containers not finding Docker

**Symptom:** VS Code Dev Containers can't connect to Docker.

**Solution:** Ensure Docker is running in WSL:
```bash
docker info  # Should show Docker info, not an error
```

If Docker is running but VS Code doesn't see it, restart VS Code completely.

---

## WSL Issues

### WSL2 not available

**Symptom:** `wsl --install` fails or WSL1 is used.

**Fix (PowerShell as Administrator):**
```powershell
# Enable required features
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart, then set WSL2 as default
wsl --set-default-version 2
```

### WSL is very slow

**Solutions:**
1. Store files in WSL filesystem, not `/mnt/c/`
2. Exclude WSL paths from Windows Defender:
   - `%USERPROFILE%\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu*`
   - `\\wsl$\Ubuntu-24.04`
3. Configure memory limits in `%USERPROFILE%\.wslconfig`:
   ```ini
   [wsl2]
   memory=8GB
   swap=2GB
   ```

### Networking issues in WSL

**Symptom:** Can't reach external URLs from WSL.

**Solutions:**
```bash
# Check DNS
cat /etc/resolv.conf

# If DNS isn't working, try Google DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

---

## Still Need Help?

1. Run `kodra doctor` and share the output
2. Open an [issue on GitHub](https://github.com/codetocloudorg/kodra-wsl/issues)
3. Ask on [Discord](https://discord.gg/vwfwq2EpXJ)
