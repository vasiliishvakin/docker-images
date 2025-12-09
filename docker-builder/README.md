# Docker-in-Docker Builder

A comprehensive Docker-in-Docker (DinD) development container with essential build tools, utilities, and SSH access. Designed for containerized CI/CD pipelines, development environments, and Docker image building workflows.

## Features

- **Docker Engine**: Latest stable Docker daemon running inside the container
- **Docker Compose**: Standalone binary for orchestrating multi-container applications
- **Docker Buildx**: Multi-platform build support for ARM, AMD64, and other architectures
- **SSH Access**: Secure remote access with public key authentication
- **Supervisor**: Process management for Docker daemon and SSH server
- **Build Tools**: Complete development toolchain (gcc, g++, make, cmake, git)
- **Development Utilities**: vim, nano, mc, htop, tmux, and more
- **Network Tools**: curl, wget, bind9-dnsutils, telnet
- **Data Processing**: jq, yq, imagemagick, ffmpeg

## Quick Start

### Build the Image

```bash
docker build -t docker-builder:latest .
```

### Run the Container

```bash
docker run -d \
  --name docker-builder \
  --privileged \
  -v docker-builder-data:/var/lib/docker \
  -p 2222:22 \
  docker-builder:latest
```

### Access via SSH

1. Add your SSH public key to the container:

```bash
docker exec docker-builder sh -c "echo 'YOUR_SSH_PUBLIC_KEY' >> /root/.ssh/authorized_keys"
```

2. Connect via SSH:

```bash
ssh -p 2222 root@localhost
```

## Configuration

### Required Volume Mount

**Important**: You must mount `/var/lib/docker` as a volume to persist Docker data (images, containers, volumes):

```bash
-v docker-builder-data:/var/lib/docker
```

Without this mount, all Docker data will be lost when the container stops.

### Privileged Mode

The container requires `--privileged` mode to run Docker daemon inside Docker:

```bash
--privileged
```

### Port Mapping

- **Port 22**: SSH server for remote access

### Environment Variables

- `DEBIAN_FRONTEND=noninteractive`: Pre-configured for non-interactive installations

## Usage Examples

### Building Docker Images

```bash
# SSH into the container
ssh -p 2222 root@localhost

# Build an image
docker build -t myapp:latest .

# Use Docker Compose
docker-compose up -d

# Multi-platform builds with buildx
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest .
```

### CI/CD Integration

```yaml
# Example GitLab CI configuration
build:
  image: docker-builder:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

## Monitoring

### Health Check

The container includes a health check that monitors both Docker daemon and SSH server:

```bash
docker inspect --format='{{.State.Health.Status}}' docker-builder
```

### Supervisor Status

Check process status inside the container:

```bash
docker exec docker-builder supervisorctl status
```

Expected output:
```
dockerd                          RUNNING   pid 123, uptime 0:01:00
sshd                             RUNNING   pid 456, uptime 0:01:00
```

### Logs

View Docker daemon logs:
```bash
docker exec docker-builder tail -f /var/log/docker/dockerd.log
```

View SSH server logs:
```bash
docker exec docker-builder tail -f /var/log/supervisor/sshd.log
```

## Security Considerations

### SSH Authentication

- **Public key authentication only**: Password authentication is disabled
- **Root access**: SSH is configured for root login with key-based auth
- **Key management**: Add authorized keys before exposing the container to networks

### Privileged Mode

This container runs in privileged mode, which grants extended permissions. Only use in trusted environments:

- Development environments
- Isolated CI/CD pipelines
- Private networks with restricted access

**Do not expose this container directly to the internet.**

## Customization

### Adding Additional Tools

Edit the Dockerfile to include additional packages:

```dockerfile
RUN apt-get update && \
    apt-get install -y \
    your-package-here \
    && rm -rf /var/lib/apt/lists/*
```

### Modifying Supervisor Configuration

Edit [supervisord.conf](supervisord.conf) to add or modify managed processes.

### SSH Configuration

Modify SSH settings in the Dockerfile:

```dockerfile
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
```

## Troubleshooting

### Docker Daemon Won't Start

Check supervisor logs:
```bash
docker logs docker-builder
docker exec docker-builder supervisorctl tail dockerd stderr
```

Common causes:
- Missing `--privileged` flag
- Volume mount issues
- Port conflicts

### SSH Connection Refused

1. Verify SSH is running:
```bash
docker exec docker-builder supervisorctl status sshd
```

2. Check SSH logs:
```bash
docker exec docker-builder tail -f /var/log/supervisor/sshd.log
```

3. Ensure authorized_keys is properly configured:
```bash
docker exec docker-builder cat /root/.ssh/authorized_keys
```

### Container Health Check Failing

Check which service is failing:
```bash
docker exec docker-builder supervisorctl status
```

Restart failed services:
```bash
docker exec docker-builder supervisorctl restart dockerd
docker exec docker-builder supervisorctl restart sshd
```

## Architecture

### Base Image
- **Debian Trixie Slim**: Lightweight, stable Debian base

### Process Management
- **Supervisord**: Manages Docker daemon and SSH server as persistent services
- **Init System**: Uses tini as a lightweight init system

### Network Architecture
- Docker daemon listens on Unix socket: `unix:///var/run/docker.sock`
- SSH server listens on port 22

## Development

### Local Testing

```bash
# Build
docker build -t docker-builder:dev .

# Run with test SSH key
docker run -d \
  --name docker-builder-test \
  --privileged \
  -v docker-test:/var/lib/docker \
  docker-builder:dev

# Add your SSH key
cat ~/.ssh/id_rsa.pub | docker exec -i docker-builder-test sh -c "cat >> /root/.ssh/authorized_keys"

# Test SSH connection
ssh -p 22 root@$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker-builder-test)
```

### Rebuilding

```bash
docker build --no-cache -t docker-builder:latest .
```

## Contributing

Contributions are welcome! Please ensure:
- Dockerfile follows best practices
- Documentation is updated
- Changes are tested in isolation

## License

This project is provided as-is for development and CI/CD purposes.

## Version Information

- **Base OS**: Debian Trixie (Debian 13)
- **Docker**: Latest stable from official Docker repository
- **Docker Compose**: Latest release from GitHub
- **Docker Buildx**: Latest release from GitHub

For specific version information, inspect the running container:

```bash
docker exec docker-builder docker --version
docker exec docker-builder docker-compose --version
docker exec docker-builder docker buildx version
```
