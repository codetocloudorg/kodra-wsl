#!/usr/bin/env bash
#
# Terraform Installation
#

source "$KODRA_DIR/lib/utils.sh" 2>/dev/null || true
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

show_installing "Terraform"

if command_exists terraform; then
    version=$(terraform version -json 2>/dev/null | jq -r '.terraform_version' || terraform version 2>/dev/null | head -1 | awk '{print $2}')
    show_installed "Terraform ($version)"
    exit 0
fi

# Add HashiCorp GPG key and repository
wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 2>/dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

sudo apt-get update -qq
sudo apt-get install -y -qq terraform >/dev/null 2>&1

if command_exists terraform; then
    version=$(terraform version -json 2>/dev/null | jq -r '.terraform_version' || echo "installed")
    show_installed "Terraform ($version)"
else
    show_warn "Terraform installation failed"
fi
