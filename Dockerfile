FROM php:7.4-fpm-bullseye

LABEL maintainer="Vasilii Shvakin <vasilii.shvakin@gmail.com>"

RUN apt-get update && apt-get -y dist-upgrade && apt-get -y install procps wget curl ca-certificates iputils-ping fping moreutils imagemagick graphviz nano build-essential make &&\
    update-ca-certificates &&\
    ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

ADD https://github.com/gordalina/cachetool/releases/latest/download/cachetool.phar /usr/local/bin
RUN chmod +x /usr/local/bin/cachetool.phar && mv /usr/local/bin/cachetool.phar /usr/local/bin/cachetool

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions apcu bcmath bz2 curl decimal ds exif gd gettext gmp imagick imap intl mbstring mongodb msgpack mysqli opcache pcntl pdo pdo-mysql redis sockets xml xsl yaml zip

RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
