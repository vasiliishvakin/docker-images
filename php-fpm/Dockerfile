ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm-trixie

LABEL maintainer="Vasilii Shvakin <vasilii.shvakin@gmail.com>"

# Environment variables
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV MAKEFLAGS="-j$(nproc)"

# Install base packages and configure system
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    debian-archive-keyring \
    gnupg2 \
    lsb-release \
    curl \
    wget \
    locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && sed -i '/ru_RU.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && update-ca-certificates \
    && ln -snf /usr/share/zoneinfo/UTC /etc/localtime \
    && echo UTC > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Install system packages
RUN apt-get update && apt-get -y dist-upgrade && apt-get install -y --no-install-recommends \
    # Essential tools
    git \
    unzip \
    zip \
    # File processing utilities
    imagemagick \
    graphviz \
    ffmpeg \
    # Image optimizers
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    webp \
    libavif-bin \
    # PHP extension dependencies
    libmagickwand-dev \
    libpq-dev \
    libc-client-dev \
    libkrb5-dev \
    libssl-dev \
    libevent-dev \
    libgmp-dev \
    libicu-dev \
    libzip-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    libzstd-dev \
    librabbitmq-dev \
    liblz4-dev \
    libmpdec-dev \
    libonig-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# PHP configuration (production mode)
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && mkdir -p /var/log/php

COPY ./php/conf.d/*.ini $PHP_INI_DIR/conf.d/

# Install PHP core extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure sysvmsg --enable-sysvmsg \
    && docker-php-ext-configure sysvsem --enable-sysvsem \
    && docker-php-ext-configure sysvshm --enable-sysvshm \
    && docker-php-ext-install -j$(nproc) \
        gd \
        sqlite3 \
        mysqli \
        pdo_mysql \
        pdo_pgsql \
        imap \
        opcache \
        exif \
        gettext \
        gmp \
        intl \
        mbstring \
        pcntl \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        xml \
        xsl \
        zip

# Install PHP PECL extensions (production essentials)
RUN pecl install amqp \
    && pecl install apcu \
    && pecl install decimal \
    && pecl install ds \
    && pecl install event \
    && pecl install imagick \
    && pecl install lz4 \
    && pecl install mongodb \
    && pecl install msgpack \
    && pecl install redis \
    && pecl install simdjson \
    && pecl install yaml \
    && pecl install zstd \
    && pecl install igbinary \
    && docker-php-ext-enable \
        amqp \
        apcu \
        decimal \
        ds \
        event \
        imagick \
        lz4 \
        mongodb \
        msgpack \
        redis \
        simdjson \
        yaml \
        zstd \
        igbinary

# Install Composer (for Laravel/Symfony artisan, migrations)
RUN php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# Final cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Workspace
WORKDIR /var/www/html

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD php-fpm-healthcheck || exit 1

# Create healthcheck script
RUN echo '#!/bin/sh' > /usr/local/bin/php-fpm-healthcheck \
    && echo 'SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1' >> /usr/local/bin/php-fpm-healthcheck \
    && chmod +x /usr/local/bin/php-fpm-healthcheck

# Expose PHP-FPM port
EXPOSE 9000

# Run PHP-FPM
CMD ["php-fpm"]
