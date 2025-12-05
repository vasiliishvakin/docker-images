# DevBox - Development Container

Professional all-in-one development environment with PHP 8.x, Node.js, Python, Go, and Java.

## Quick Start

```bash
# Build
docker build -t devbox:latest .

# Run
docker run -d --name devbox -p 2222:22 -v workspace:/workspace devbox:latest

# Connect
ssh root@localhost -p 2222
```

## Tech Stack

### PHP 8.3
- **21 Core Extensions**: gd, mysqli, pdo_mysql, pdo_pgsql, imap, opcache, intl, mbstring, xml, zip, etc.
- **15 PECL Extensions**: redis, mongodb, xdebug, imagick, amqp, apcu, yaml, igbinary, etc.
- **Composer**: Includes phpstan, php-cs-fixer, rector, deployer, laravel/installer

### Runtime Environments
- **Node.js 25.x** with typescript, eslint, prettier, nodemon
- **Python 3** with black, pytest, mypy, pylint, debugpy
- **Go** compiler
- **Java** OpenJDK

### Database Clients
- MariaDB/MySQL client

### Development Tools
- **Editors**: vim, nano, mc
- **Terminal**: tmux, bash-completion
- **Network**: net-tools, telnet, bind9-dnsutils
- **Utilities**: git, htop, tree, jq, rsync, strace, patch
- **Archives**: zip, unzip

## Configuration

### PHP Settings (Development Mode)
```ini
memory_limit = 256M
max_execution_time = 300
display_errors = On
xdebug.mode = develop,coverage,debug,profile
```

Configuration file: `php/conf.d/devbox.ini`

### Xdebug
Pre-configured for debugging, profiling, and coverage. Trigger mode enabled.

### MailHog Integration
Built-in mhsendmail for email testing with MailHog.

## Volume Mounts

Recommended mounts:

```bash
docker run -d \
  -p 2222:22 \
  -v workspace:/workspace \
  -v devbox-composer:/root/.config/composer \
  -v devbox-npm:/root/.npm \
  devbox:latest
```

## Optimization

This image is optimized following Docker and PHP best practices:

- ✅ Minimal layers (15 vs 30+)
- ✅ Efficient layer ordering for caching
- ✅ Official PHP tools only (docker-php-ext-*, pecl)
- ✅ `--no-install-recommends` everywhere
- ✅ Cache cleanup after each apt-get
- ✅ HTTPS for package downloads

See [DOCKERFILE_OPTIMIZATION.md](DOCKERFILE_OPTIMIZATION.md) for details.

## Build with BuildKit

```bash
DOCKER_BUILDKIT=1 docker build -t devbox:latest .
```

## Use Cases

- Full-stack PHP development (Laravel, Symfony, WordPress)
- Multi-language projects
- Testing environments
- CI/CD pipelines
- Learning and experimentation

## Image Info

- **Base**: php:8.x-cli (Debian Trixie)
- **Entrypoint**: tini
- **Default CMD**: sshd
- **Exposed Port**: 22

## License

Apache 2.0
