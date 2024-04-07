FROM vasiliishavkin/php:5.6-fpm

LABEL maintainer="Vasilii Shvakin <vasilii.shvakin@gmail.com>"

RUN apt-get update && apt-get -y dist-upgrade && apt-get -y install graphviz ssh mc htop tmux nano colordiff gnupg

RUN install-php-extensions xdebug

RUN echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

RUN wget -O graph-composer.phar https://clue.engineering/graph-composer-latest.phar && chmod +x graph-composer.phar && mv graph-composer.phar /usr/local/bin/graph-composer

RUN rm -rf /var/lib/apt/lists/*

WORKDIR /app
