ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-cli--trixie

LABEL maintainer="Vasilii Shvakin <vasilii.shvakin@gmail.com>"

# Environment variables
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV MAKEFLAGS="-j$(nproc)"
ENV PATH="$PATH:/root/.config/composer/vendor/bin"

# Install base packages and configure system (before adding repositories)
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    debian-archive-keyring \
    gnupg2 \
    lsb-release \
    curl \
    wget \
    locales \
    openssh-server \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && sed -i '/he_IL.UTF-8/s/^# //g' /etc/locale.gen \
    && sed -i '/ru_RU.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && update-ca-certificates \
    && ln -snf /usr/share/zoneinfo/UTC /etc/localtime \
    && echo UTC > /etc/timezone \
    && mkdir -p /run/sshd && chmod 0755 /run/sshd \
    && ssh-keygen -A \
    && rm -rf /var/lib/apt/lists/*

# SSH configuration
COPY ./ssh/sshd_config /etc/ssh/sshd_config

# Add MariaDB repository
RUN mkdir -p /etc/apt/keyrings \
    && curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'

COPY ./apt/sources.list.d/* /etc/apt/sources.list.d/

# Install all system packages in one layer
RUN apt-get update && apt-get -y dist-upgrade && apt-get install -y --no-install-recommends \
    # MariaDB client
    mariadb-client \
    # Development tools
    build-essential \
    make \
    git \
    # System utilities
    procps \
    iputils-ping \
    fping \
    moreutils \
    imagemagick \
    graphviz \
    nano \
    vim \
    bind9-dnsutils \
    colordiff \
    ffmpeg \
    htop \
    mc \
    sudo \
    tmux \
    links2 \
    software-properties-common \
    man \
    bash-completion \
    most \
    jq \
    rsync \
    yq \
    pv \
    tini \
    tree \
    net-tools \
    telnet \
    unzip \
    zip \
    patch \
    strace \
    # Image optimizers
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    webp \
    libavif-bin \
    # Languages
    golang-go \
    default-jdk \
    python3 \
    python3-distutils \
    python3-venv \
    python3-pip \
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

# PHP configuration
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
    && mkdir -p /var/log/php /var/lib/php/profiling

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

# Install PHP PECL extensions (using latest stable versions)
# Extensions installed in series to fail properly if something goes wrong
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
    && pecl install xdebug \
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
    igbinary \
    xdebug

# Install Composer and global packages
RUN php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && composer global require --no-progress --no-interaction \
    jbzoo/composer-diff \
    jbzoo/composer-graph \
    deployer/deployer \
    rector/rector \
    friendsofphp/php-cs-fixer \
    phpstan/phpstan \
    laravel/installer

# Install Node.js and global packages
RUN curl -fsSL https://deb.nodesource.com/setup_25.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g nodemon typescript ts-node eslint prettier svgo \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
COPY ./python/requirements.txt /tmp/requirements.txt
RUN wget -q https://bootstrap.pypa.io/get-pip.py \
    && python3 get-pip.py --break-system-packages \
    && python3 -m pip install --upgrade pip --break-system-packages \
    && python3 -m pip install --no-cache-dir -r /tmp/requirements.txt --break-system-packages \
    && rm -f get-pip.py /tmp/requirements.txt

# Install mhsendmail
RUN wget https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \
    && chmod +x mhsendmail_linux_amd64 \
    && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail

# Final cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Workspace
WORKDIR /workspace

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/sbin/sshd", "-D", "-e"]

EXPOSE 22
