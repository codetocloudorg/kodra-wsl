#!/usr/bin/env bash
#
# OpenTofu Installation - Open source Terraform alternative
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "OpenTofu"

if command_exists tofu; then
    version=$(tofu --version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "OpenTofu ($version)"
    exit 0
fi

# Install OpenTofu via official installer
# https://opentofu.org/docs/intro/install/

# Add OpenTofu repository
curl -fsSL https://get.opentofu.org/install-opentofu.sh -o /tmp/install-opentofu.sh 2>/dev/null
chmod +x /tmp/install-opentofu.sh
sudo /tmp/install-opentofu.sh --install-method deb >/dev/null 2>&1
rm -f /tmp/install-opentofu.sh

# Fallback: binary install if apt method fails
if ! command_exists tofu; then
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
    esac
    
    TOFU_VERSION=$(curl -s https://api.github.com/repos/opentofu/opentofu/releases/latest | jq -r '.tag_name' | tr -d 'v')
    wget -qO /tmp/tofu.zip "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_${ARCH}.zip" 2>/dev/null
    if [ -f /tmp/tofu.zip ]; then
        sudo unzip -o /tmp/tofu.zip -d /usr/local/bin tofu >/dev/null 2>&1
        rm -f /tmp/tofu.zip
    fi
fi

if command_exists tofu; then
    version=$(tofu --version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "OpenTofu ($version)"
else
    show_warn "OpenTofu installation failed"
fi
