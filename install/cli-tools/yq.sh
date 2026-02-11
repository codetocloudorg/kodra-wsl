#!/usr/bin/env bash
# yq - YAML processor
source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "yq"

if command_exists yq; then
    version=$(yq --version 2>/dev/null | awk '{print $4}')
    show_installed "yq ($version)"
    exit 0
fi

YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.tag_name')
ARCH=$(dpkg --print-architecture)

wget -qO /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH}" 2>/dev/null || \
sudo wget -qO /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH}" 2>/dev/null
sudo chmod +x /usr/local/bin/yq

if command_exists yq; then
    version=$(yq --version 2>/dev/null | awk '{print $4}')
    show_installed "yq ($version)"
else
    show_warn "yq installation failed"
fi
