# Azure VM Testing Guide

This guide explains how to test Kodra WSL installation using an Azure VM running Ubuntu. This is useful for:

- CI/CD validation
- Testing installation without a Windows machine
- Verifying tool installations work correctly

## Overview

While Kodra WSL is designed for Windows Subsystem for Linux, the core installation (CLI tools, Docker, Azure tools) works identically on native Ubuntu. We use Azure VMs to test the installation scripts before releasing.

## Prerequisites

- Azure CLI installed and authenticated (`az login`)
- An Azure subscription
- SSH key pair (or Azure will generate one)

## Quick Start

### 1. Create Test VM

```bash
# Set variables
RG_NAME="kodra-wsl-test"
VM_NAME="kodra-test-vm"
LOCATION="eastus"

# Create resource group
az group create --name $RG_NAME --location $LOCATION

# Create Ubuntu 24.04 VM
az vm create \
    --resource-group $RG_NAME \
    --name $VM_NAME \
    --image Ubuntu2404 \
    --size Standard_D2s_v3 \
    --admin-username kodra \
    --generate-ssh-keys \
    --public-ip-sku Standard

# Get the public IP
VM_IP=$(az vm show -d -g $RG_NAME -n $VM_NAME --query publicIps -o tsv)
echo "VM IP: $VM_IP"
```

### 2. Connect to VM

```bash
ssh kodra@$VM_IP
```

### 3. Run Installation

```bash
# Run the Kodra WSL installer
wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash
```

### 4. Verify Installation

```bash
# Run health check
kodra doctor

# Test individual tools
docker --version
az --version
gh --version
kubectl version --client
```

### 5. Clean Up

```bash
# Delete the resource group (and all resources in it)
az group delete --name kodra-wsl-test --yes --no-wait
```

## Automated Testing Script

Save this as `test-azure-vm.sh`:

```bash
#!/usr/bin/env bash
#
# Automated Kodra WSL Testing on Azure VM
#

set -e

RG_NAME="kodra-wsl-test-$(date +%Y%m%d%H%M%S)"
VM_NAME="kodra-test"
LOCATION="eastus"

echo "Creating test environment: $RG_NAME"

# Create resource group
az group create --name $RG_NAME --location $LOCATION --output none

# Create VM
echo "Creating Ubuntu 24.04 VM..."
az vm create \
    --resource-group $RG_NAME \
    --name $VM_NAME \
    --image Ubuntu2404 \
    --size Standard_D2s_v3 \
    --admin-username kodra \
    --generate-ssh-keys \
    --public-ip-sku Standard \
    --output none

# Get IP
VM_IP=$(az vm show -d -g $RG_NAME -n $VM_NAME --query publicIps -o tsv)
echo "VM IP: $VM_IP"

# Wait for VM to be ready
echo "Waiting for VM to be ready..."
sleep 30

# Run installation test
echo "Running Kodra WSL installation..."
ssh -o StrictHostKeyChecking=no kodra@$VM_IP << 'EOF'
    # Run installer
    wget -qO- https://raw.githubusercontent.com/codetocloudorg/kodra-wsl/main/boot.sh | bash --install
    
    # Source new shell config
    source ~/.zshrc 2>/dev/null || source ~/.bashrc
    
    # Run doctor
    ~/.kodra/bin/kodra doctor
    
    # Test key tools
    echo ""
    echo "Testing tools..."
    docker --version || echo "Docker: FAILED"
    az --version | head -1 || echo "Azure CLI: FAILED"
    gh --version | head -1 || echo "GitHub CLI: FAILED"
    kubectl version --client -o json | jq -r '.clientVersion.gitVersion' || echo "kubectl: FAILED"
    terraform version | head -1 || echo "Terraform: FAILED"
    
    echo ""
    echo "Test complete!"
EOF

# Cleanup
echo ""
read -p "Delete test resources? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Cleaning up..."
    az group delete --name $RG_NAME --yes --no-wait
    echo "Cleanup initiated (runs in background)"
fi
```

## VM Sizes for Testing

| Size | vCPUs | Memory | Cost | Use Case |
|------|-------|--------|------|----------|
| Standard_B2s | 2 | 4 GB | ~$30/mo | Basic testing |
| Standard_D2s_v3 | 2 | 8 GB | ~$70/mo | Docker testing |
| Standard_D4s_v3 | 4 | 16 GB | ~$140/mo | Full testing |

For quick tests, use Spot instances to save ~60-90%:

```bash
az vm create \
    --resource-group $RG_NAME \
    --name $VM_NAME \
    --image Ubuntu2404 \
    --size Standard_D2s_v3 \
    --priority Spot \
    --eviction-policy Deallocate \
    --admin-username kodra \
    --generate-ssh-keys
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Test Kodra WSL Installation

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test-install:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Installation
        run: |
          chmod +x boot.sh install.sh
          ./boot.sh --install
      
      - name: Run Doctor
        run: ~/.kodra/bin/kodra doctor
      
      - name: Test Docker
        run: docker run hello-world
      
      - name: Test Azure CLI
        run: az --version
```

## Differences from WSL

When testing on Azure VM (native Ubuntu), note these differences:

| Feature | WSL | Azure VM |
|---------|-----|----------|
| Docker | Runs in WSL2 kernel | Runs natively |
| Networking | WSL NAT | Direct Azure networking |
| Filesystem | Faster on Linux paths | Native Linux |
| VS Code | Remote-WSL extension | Remote-SSH extension |

The installation scripts detect the environment and adjust accordingly:

```bash
# In boot.sh, we detect:
if grep -qEi "(microsoft|wsl)" /proc/version 2>/dev/null; then
    IS_WSL=true
elif curl -s -H "Metadata:true" "http://169.254.169.254/metadata/instance" 2>/dev/null | grep -q "azure"; then
    IS_AZURE_VM=true
fi
```

## Troubleshooting

### SSH Connection Refused

Wait longer for VM to boot, or check NSG rules:

```bash
az vm open-port --resource-group $RG_NAME --name $VM_NAME --port 22
```

### Out of Memory

Use a larger VM size or add swap:

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Docker Permission Denied

Log out and back in, or manually add to group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

## Cost Optimization

1. **Delete when done**: Always delete test VMs after testing
2. **Use Spot instances**: 60-90% cheaper, fine for testing
3. **Use small VMs**: B2s is sufficient for most tests
4. **Auto-shutdown**: Configure auto-shutdown in Azure portal

```bash
# Create with auto-shutdown at 7 PM
az vm auto-shutdown \
    --resource-group $RG_NAME \
    --name $VM_NAME \
    --time 1900
```
