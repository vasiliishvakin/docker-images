FROM php:5.6-fpm-stretch

LABEL maintainer="Vasilii Shvakin <vasilii.shvakin@gmail.com>"

RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions gd mysqli pdo_mysql bcmath gmp bz2 intl xsl

RUN apt-get -y update; apt-get -y upgrade && apt-get -y dist-upgrade && apt-get -y install procps wget curl ca-certificates iputils-ping dnsutils moreutils ffmpeg imagemagick graphviz ssh mc htop tmux nano colordiff gnupg

RUN update-ca-certificates

RUN rm -rf /var/lib/apt/lists/*
