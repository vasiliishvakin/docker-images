FROM php:8.3-cli-bookworm

LABEL maintainer="Vasilii Shvakin <vasilii.shvakin@gmail.com>"

RUN apt-get update && apt-get -y dist-upgrade &&\
    apt-get -y install procps wget curl ca-certificates iputils-ping fping moreutils imagemagick golang-go \
    graphviz nano build-essential make bind9-dnsutils colordiff dnsutils ffmpeg git gnupg htop mc ssh sudo tmux links2 \
    software-properties-common python3 apt-transport-https \
    gnupg2 ca-certificates lsb-release debian-archive-keyring \
    bash-completion \
    default-jdk \
    jq rsync yq  pv \
    dumb-init

RUN  update-ca-certificates && ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

#add repos
RUN mkdir -p /etc/apt/keyrings &&\
    curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'

COPY ./apt/sources.list.d/* /etc/apt/sources.list.d/

#docker for vscode connection to parent
RUN install -m 0755 -d /etc/apt/keyrings &&\
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&\
    chmod a+r /etc/apt/keyrings/docker.gpg &&\
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" >> /etc/apt/sources.list.d/docker.list &&\
    apt-get update && sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#PHP
COPY ./php/php.ini /usr/local/etc/php/php.ini
RUN mkdir -p /var/log/php

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && install-php-extensions amqp gd sqlite3 mysqli mysqlnd "pdo_mysql" "pdo_pgsql" imap opcache apcu decimal ds event exif gettext gmp imagick intl lz4 mbstring mongodb msgpack redis simdjson sockets xml xsl yaml zip zstd

RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# xdebug
RUN install-php-extensions xdebug \
    && echo "xdebug.mode=develop,coverage,debug,profile;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host = localhost;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request = trigger;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_output_name=cachegrind.out.%t;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.output_dir = /var/lib/php/profiling;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

#graph-composer
RUN wget -O graph-composer.phar https://clue.engineering/graph-composer-latest.phar && chmod +x graph-composer.phar && mv graph-composer.phar /usr/local/bin/graph-composer

#nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - &&\
    apt-get install -y nodejs &&\
    npm install -g nodemon typescript ts-node eslint prettier

#python
COPY ./python/requirements.txt ./
RUN wget https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py --break-system-packages &&\
    python3 -m pip install --upgrade pip --break-system-packages && python3 -m pip install --no-cache-dir -r requirements.txt --break-system-packages

#restic
RUN wget https://github.com/restic/restic/releases/download/v0.17.0/restic_0.17.0_linux_amd64.bz2 &&\
    bzip2 -d restic_0.17.0_linux_amd64.bz2 &&\
    chmod +x restic_0.17.0_linux_amd64 &&\
    mv restic_0.17.0_linux_amd64 /usr/local/bin/restic

#mhsendmail
RUN wget https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 &&\
    chmod +x mhsendmail_linux_amd64 && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail

#logdy
RUN curl https://logdy.dev/install.sh | sh

RUN apt-get -y dist-upgrade && apt-get clean

#configs
COPY ./user/* /root/

RUN mkdir -p /etc/container-inid &&\
    mkdir -p /etc/container-inid.d

COPY ./container-init/container-init.sh /etc/container-init.sh
COPY ./container-init/container-init/* /etc/container-inid/

#workspace
RUN mkdir -p /workspace && chmod 777 /workspace
WORKDIR /workspace

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "-c", "/etc/container-init.sh"]

# EXPOSE 80
# EXPOSE 5173
