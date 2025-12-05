# PHP-FPM - Production Container

Production-ready PHP-FPM image optimized for public hosting with Caddy server.

## Quick Start

```bash
# Build
docker build -t php-fpm:latest .

# Run with Caddy
docker run -d \
  --name php-fpm \
  -v /path/to/app:/var/www/html \
  php-fpm:latest
```

## Tech Stack

### PHP 8.x (FPM)
- **21 Core Extensions**: gd, mysqli, pdo_mysql, pdo_pgsql, imap, opcache, intl, mbstring, xml, zip, etc.
- **14 PECL Extensions**: redis, mongodb, imagick, amqp, apcu, yaml, igbinary, etc.
- **Composer**: For Laravel/Symfony artisan commands and migrations

## Production Optimizations

### Performance
- **OPcache**: Enabled with optimal settings
- **JIT**: Ready for PHP 8.3+
- **APCu**: User cache enabled
- **FastCGI**: Optimized for Caddy/Nginx

### Security
- `display_errors = Off`
- `expose_php = Off`
- Secure session cookies (httponly, secure, samesite)
- `allow_url_include = Off`

### Configuration
```ini
memory_limit = 256M
max_execution_time = 60
post_max_size = 20M
upload_max_filesize = 20M
opcache.validate_timestamps = 0
```

Configuration file: `php/conf.d/production.ini`

## Usage with Caddy

### docker-compose.yml

```yaml
version: '3.8'

services:
  caddy:
    image: caddy:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./app:/var/www/html
      - caddy_data:/data
      - caddy_config:/config
    depends_on:
      - php

  php:
    image: php-fpm:latest
    volumes:
      - ./app:/var/www/html
    environment:
      - PHP_OPCACHE_VALIDATE_TIMESTAMPS=0

volumes:
  caddy_data:
  caddy_config:
```

### Caddyfile

```caddyfile
example.com {
    root * /var/www/html/public

    encode gzip

    php_fastcgi php:9000

    file_server
}
```

## Health Check

Built-in health check for monitoring:

```bash
docker inspect --format='{{.State.Health.Status}}' php-fpm
```

## Environment Variables

Optional runtime configuration:

```bash
docker run -d \
  -e PHP_OPCACHE_VALIDATE_TIMESTAMPS=1 \
  -e PHP_MEMORY_LIMIT=512M \
  php-fpm:latest
```

## Framework Support

### Laravel
```bash
# Run migrations
docker exec php-fpm php artisan migrate

# Clear cache
docker exec php-fpm php artisan cache:clear
docker exec php-fpm php artisan config:clear
docker exec php-fpm php artisan route:clear
docker exec php-fpm php artisan view:clear

# Optimize for production
docker exec php-fpm php artisan optimize
```

### Symfony
```bash
# Run migrations
docker exec php-fpm php bin/console doctrine:migrations:migrate

# Clear cache
docker exec php-fpm php bin/console cache:clear --env=prod
```

## Volume Mounts

Recommended mounts:

```bash
docker run -d \
  -v /path/to/app:/var/www/html \
  -v php-logs:/var/log/php \
  -v composer-cache:/root/.composer/cache \
  php-fpm:latest
```

## Image Info

- **Base**: php:8.x-fpm (Debian Trixie)
- **Working Directory**: /var/www/html
- **Exposed Port**: 9000 (FastCGI)
- **Health Check**: Enabled

## Build with BuildKit

```bash
DOCKER_BUILDKIT=1 docker build -t php-fpm:latest .
```

## License

Apache 2.0
