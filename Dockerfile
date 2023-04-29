FROM php:8.2-fpm-bullseye

LABEL maintainer="Vasilii Shvakin <vasilii.shvakin@gmail.com>"
MAINTAINER Vasilii Shvakin <vasilii.shvakin@gmail.com>

RUN apt-get update && apt-get -y dist-upgrade && apt-get -y install procps wget curl ca-certificates iputils-ping bind9-dnsutils

RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

ADD https://github.com/gordalina/cachetool/releases/latest/download/cachetool.phar /usr/local/bin
RUN chmod +x /usr/local/bin/cachetool.phar && mv /usr/local/bin/cachetool.phar /usr/local/bin/cachetool

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions gd pdo_mysql redis apcu imagick yaml igbinary mbstring xml bcmath gmp decimal bz2 curl intl opcache xsl zip msgpack

RUN rm -rf /var/lib/apt/lists/*
