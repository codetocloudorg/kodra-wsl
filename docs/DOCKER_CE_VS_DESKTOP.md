# Docker CE vs Docker Desktop: Complete Comparison

## Overview

Kodra WSL installs **Docker CE (Community Edition)** directly in WSL2, providing a **free alternative to Docker Desktop** that runs natively on the Linux kernel.

## Licensing Comparison

| | Docker CE (Kodra WSL) | Docker Desktop |
|---|---|---|
| **Cost** | **Free forever** | Free for individuals, $5-24/user/month for business |
| **License Required?** | No | Yes, for orgs with 250+ employees or $10M+ revenue |
| **Commercial Use** | Unrestricted | Requires paid subscription for qualifying orgs |
| **Open Source** | Yes (Apache 2.0) | Proprietary GUI with open-source engine |

### Docker Desktop Pricing (as of 2026)

| Plan | Price | Requirement |
|------|-------|-------------|
| Personal | Free | Individuals, education, small business (<250 employees AND <$10M revenue) |
| Pro | $5/user/month | Individual professionals |
| Team | $9/user/month | Development teams |
| Business | $24/user/month | Large organizations |

**Example savings with Docker CE via Kodra WSL:**

| Company Size | Docker Desktop Annual Cost | Kodra WSL Cost | Annual Savings |
|---|---|---|---|
| 50 developers | $5,400/year (Pro) | **$0** | **$5,400** |
| 200 developers | $21,600/year (Team) | **$0** | **$21,600** |
| 500 developers | $144,000/year (Business) | **$0** | **$144,000** |

## Feature Comparison

| Feature | Docker CE in WSL2 | Docker Desktop |
|---------|-------------------|----------------|
| **Container Runtime** | ✅ containerd/runc | ✅ containerd/runc |
| **Docker Compose** | ✅ v2 (plugin) | ✅ v2 (built-in) |
| **Docker Build** | ✅ BuildKit | ✅ BuildKit |
| **Volume Mounts** | ✅ Native Linux | ✅ Via VM translation |
| **Networking** | ✅ Native Linux | ✅ Via vpnkit |
| **GUI Dashboard** | ❌ (use lazydocker) | ✅ Desktop app |
| **Kubernetes** | ❌ (use kubectl/k9s) | ✅ Built-in K8s |
| **Extensions** | ❌ | ✅ Docker Extensions |
| **Dev Environments** | ✅ VS Code Dev Containers | ✅ Docker Dev Environments |
| **Scan/Scout** | ✅ CLI available | ✅ Built-in |
| **Auto-Updates** | Via `kodra update` | ✅ Built-in |
| **WSL2 Backend** | ✅ Native | ✅ Uses WSL2 |

## Performance Comparison

| Metric | Docker CE in WSL2 | Docker Desktop |
|--------|-------------------|----------------|
| **Startup Time** | ~1s (WSL boot) | ~10-30s (app launch) |
| **RAM Overhead** | ~50MB (daemon only) | ~1-2GB (app + VM) |
| **Disk Usage** | ~500MB | ~2-4GB |
| **Build Speed** | Native Linux speed | Near-native (via WSL2) |
| **I/O Performance** | Native ext4 | Translated via 9P/virtiofs |

> Docker Desktop actually uses WSL2 under the hood for its Linux containers. With Docker CE in WSL2, you skip the Docker Desktop layer entirely.

## When to Use Each

### Use Docker CE in WSL2 (Kodra WSL) When:
- Your company requires Docker Desktop licenses and you want to avoid cost
- You prefer CLI-based workflows
- You want lower resource usage
- You're already working in WSL2
- You need CI/CD parity (same Docker as your pipelines)
- You want the simplest, most direct Docker experience

### Use Docker Desktop When:
- You need the GUI dashboard (though lazydocker is excellent)
- You need Docker Extensions marketplace
- You want built-in Kubernetes (though Kodra WSL includes kubectl, Helm, k9s)
- You work on macOS (Docker CE in WSL2 is Windows-only)
- Your company already has Docker Desktop licenses

## Migration Guide: Docker Desktop to Docker CE

### Step 1: Export Important Data

```bash
# List your Docker Desktop containers
docker ps -a

# Export volumes you want to keep
docker run --rm -v my_volume:/data -v $(pwd):/backup alpine tar czf /backup/my_volume.tar.gz /data
```

### Step 2: Uninstall Docker Desktop

1. Open Windows Settings → Apps → Docker Desktop → Uninstall
2. Restart your computer

### Step 3: Install Kodra WSL

```bash
# In WSL2 Ubuntu terminal
wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash
```

### Step 4: Restore Data

```bash
# Import volumes
docker volume create my_volume
docker run --rm -v my_volume:/data -v $(pwd):/backup alpine tar xzf /backup/my_volume.tar.gz -C /

# Pull your images
docker pull your-image:tag
```

### Step 5: Update VS Code

If using Dev Containers, no changes needed — VS Code automatically detects Docker in WSL2.

## FAQ

**Q: Will my Docker Compose files work?**
A: Yes, Docker Compose v2 is installed as a Docker CLI plugin. Use `docker compose` (no hyphen) instead of `docker-compose`.

**Q: Will Dev Containers work?**
A: Yes, VS Code Dev Containers work with Docker CE in WSL2 out of the box.

**Q: Can I run both Docker Desktop and Docker CE?**
A: Not recommended. They will conflict. Choose one.

**Q: Is Docker CE less capable than Docker Desktop?**
A: The Docker engine is identical. Docker Desktop adds a GUI and extras. For CLI workflows, Docker CE is equivalent.
