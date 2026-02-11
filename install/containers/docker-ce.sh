#!/usr/bin/env bash
#
# Docker CE Installation for WSL2
# Installs Docker CE directly in WSL2 without Docker Desktop
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Docker CE"

# Check if Docker is already installed
if command_exists docker; then
    docker_version=$(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')
    show_installed "Docker CE ($docker_version)"
    exit 0
fi

# Remove any old Docker packages
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Install prerequisites
sudo apt-get update -qq
sudo apt-get install -y -qq \
    ca-certificates \
    curl \
    gnupg \
    lsb-release >/dev/null 2>&1

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CE
sudo apt-get update -qq
sudo apt-get install -y -qq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin >/dev/null 2>&1

# Add user to docker group (so we don't need sudo)
sudo usermod -aG docker "$USER"

# Configure Docker to start with WSL
# The docker service may not start automatically in WSL without systemd
# We'll create a script to ensure it starts

mkdir -p "$HOME/.local/bin"

# Create docker-start helper script
cat > "$HOME/.local/bin/docker-wsl-start" << 'DOCKER_START'
#!/usr/bin/env bash
# Start Docker daemon in WSL if not running

if ! pgrep -x "dockerd" > /dev/null; then
    # Check if systemd is available
    if command -v systemctl &> /dev/null && systemctl is-system-running &> /dev/null; then
        sudo systemctl start docker
    else
        # Fallback: start dockerd directly
        sudo dockerd > /dev/null 2>&1 &
        sleep 2
    fi
fi
DOCKER_START
chmod +x "$HOME/.local/bin/docker-wsl-start"

# Add to shell RC to auto-start Docker
SHELL_RC="$HOME/.bashrc"
[ ! -f "$SHELL_RC" ] && SHELL_RC="$HOME/.zshrc"

if ! grep -q "docker-wsl-start" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Auto-start Docker in WSL" >> "$SHELL_RC"
    echo '[ -x "$HOME/.local/bin/docker-wsl-start" ] && "$HOME/.local/bin/docker-wsl-start" 2>/dev/null' >> "$SHELL_RC"
fi

# Try to start Docker now
if command -v systemctl &> /dev/null && systemctl is-system-running &> /dev/null 2>&1; then
    sudo systemctl enable docker 2>/dev/null || true
    sudo systemctl start docker 2>/dev/null || true
elif ! pgrep -x "dockerd" > /dev/null; then
    sudo dockerd > /dev/null 2>&1 &
    sleep 3
fi

# Verify installation
if docker --version &> /dev/null; then
    docker_version=$(docker --version | awk '{print $3}' | tr -d ',')
    show_installed "Docker CE ($docker_version)"
else
    show_installed "Docker CE (restart terminal to use)"
fi
