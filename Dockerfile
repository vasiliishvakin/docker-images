FROM vasiliishvakin/php:7.4-fpm

LABEL maintainer="Vasilii Shvakin <vasilii.shvakin@gmail.com>"

RUN apt-get update && apt-get -y dist-upgrade && apt-get -y install bind9-dnsutils colordiff dnsutils ffmpeg git gnupg htop mc ssh sudo tmux

COPY ./php-fpm.d/www.conf /usr/local/etc/php-fpm.d/
COPY  ./conf.d/zz-01-default.ini /usr/local/etc/php/conf.d/

#nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &&\
    apt-get install -y nodejs &&\
    npm install -g nodemon typescript ts-node eslint prettier

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
    && code-server --install-extension xdebug.php-debug

#composer
RUN wget -O graph-composer.phar https://clue.engineering/graph-composer-latest.phar && chmod +x graph-composer.phar && mv graph-composer.phar /usr/local/bin/graph-composer

#xdebug
RUN install-php-extensions xdebug \
    && echo "xdebug.mode=develop,coverage,debug,profile;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host = localhost;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request = trigger;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_output_name=cachegrind.out.%t;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.output_dir = /var/lib/php/profiling;" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
