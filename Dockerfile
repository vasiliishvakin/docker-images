FROM vasiliishvakin/php:7.4-fpm

LABEL maintainer="Vasilii Shvakin <vasilii.shvakin@gmail.com>"

RUN apt-get update && apt-get -y dist-upgrade && apt-get -y install bind9-dnsutils colordiff dnsutils ffmpeg git gnupg htop mc ssh sudo tmux links2

COPY ./php-fpm.d/www.conf /usr/local/etc/php-fpm.d/
COPY ./conf.d/zz-01-default.ini /usr/local/etc/php/conf.d/

#nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &&\
    apt-get install -y nodejs &&\
    npm install -g nodemon typescript ts-node eslint prettier

#docker for vscode connection to parent
RUN install -m 0755 -d /etc/apt/keyrings &&\
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&\
    chmod a+r /etc/apt/keyrings/docker.gpg &&\
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" >> /etc/apt/sources.list.d/docker.list &&\
    apt-get update && sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#restic
RUN wget https://github.com/restic/restic/releases/download/v0.16.0/restic_0.16.0_linux_amd64.bz2 &&\
    bzip2 -d restic_0.16.0_linux_amd64.bz2 &&\
    chmod +x restic_0.16.0_linux_amd64 &&\
    mv restic_0.16.0_linux_amd64 /usr/local/bin/restic

#mega
RUN wget https://mega.nz/linux/repo/Debian_11/amd64/megacmd-Debian_11_amd64.deb &&\
    apt install -y ./megacmd-Debian_11_amd64.deb &&\
    rm megacmd-Debian_11_amd64.deb  && \
    rm /etc/apt/sources.list.d/megasync.list && \
    apt-get update

#vscode-server
RUN curl -fsSL https://code-server.dev/install.sh | sh \
    && code-server --install-extension bierner.markdown-mermaid \
    && code-server --install-extension bmewburn.vscode-intelephense-client \
    && code-server --install-extension christian-kohler.path-intellisense \
    && code-server --install-extension dbaeumer.vscode-eslint \
    && code-server --install-extension DEVSENSE.composer-php-vscode \
    && code-server --install-extension DEVSENSE.profiler-php-vscode \
    && code-server --install-extension esbenp.prettier-vscode \
    && code-server --install-extension neilbrayfield.php-docblocker \
    && code-server --install-extension open-southeners.php-support-utils \
    && code-server --install-extension rvest.vs-code-prettier-eslint \
    && code-server --install-extension sleistner.vscode-fileutils \
    && code-server --install-extension streetsidesoftware.code-spell-checker \
    && code-server --install-extension xdebug.php-debug \
    && code-server --install-extension ms-azuretools.vscode-docker

#composer
RUN wget -O graph-composer.phar https://clue.engineering/graph-composer-latest.phar && chmod +x graph-composer.phar && mv graph-composer.phar /usr/local/bin/graph-composer

#xdebug
RUN install-php-extensions xdebug \
    && echo "xdebug.mode=develop,coverage,debug,profile;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host = localhost;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request = trigger;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_output_name=cachegrind.out.%t;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.output_dir = /var/lib/php/profiling;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN apt-get -y dist-upgrade && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
