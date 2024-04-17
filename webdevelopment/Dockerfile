#

FROM php:8.3-fpm-bookworm

LABEL maintainer="Vasilii Shvakin <vasilii.shvakin@gmail.com>"

RUN apt-get update && apt-get -y dist-upgrade &&\
    apt-get -y install procps wget curl ca-certificates iputils-ping fping moreutils imagemagick golang-go \
    graphviz nano build-essential make bind9-dnsutils colordiff dnsutils ffmpeg git gnupg htop mc ssh sudo tmux links2 \
    software-properties-common python3 apt-transport-https \
    gnupg2 ca-certificates lsb-release debian-archive-keyring \
    bash-completion \
    supervisor

RUN  update-ca-certificates && ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

#add repos
RUN mkdir -p /etc/apt/keyrings &&\
    curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp' &&\
    curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor  | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null &&\
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

COPY ./apt/sources.list.d/* /etc/apt/sources.list.d/

#docker for vscode connection to parent
RUN install -m 0755 -d /etc/apt/keyrings &&\
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&\
    chmod a+r /etc/apt/keyrings/docker.gpg &&\
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" >> /etc/apt/sources.list.d/docker.list &&\
    apt-get update && sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#PHP
COPY ./php/php.ini /usr/local/etc/php/php.ini
COPY ./php/php-fpm.d/* /usr/local/etc/php-fpm.d/
COPY ./php/conf.d/* /usr/local/etc/php/conf.d/

ADD https://github.com/gordalina/cachetool/releases/latest/download/cachetool.phar /usr/local/bin
RUN chmod +x /usr/local/bin/cachetool.phar && mv /usr/local/bin/cachetool.phar /usr/local/bin/cachetool

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && install-php-extensions amqp gd sqlite3 mysqlnd "pdo_mysql" "pdo_pgsql" imap opcache apcu decimal ds event exif gettext gmp imagick intl lz4 mbstring mongodb msgpack redis simdjson sockets xml xsl yaml zip zstd

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
RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash - &&\
    apt-get install -y nodejs &&\
    npm install -g nodemon typescript ts-node eslint prettier

#python
COPY ./python/requirements.txt ./
RUN wget https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py --break-system-packages &&\
    python3 -m pip install --upgrade pip --break-system-packages && python3 -m pip install --no-cache-dir -r requirements.txt --break-system-packages

#restic
RUN wget https://github.com/restic/restic/releases/download/v0.16.4/restic_0.16.4_linux_amd64.bz2 &&\
    bzip2 -d restic_0.16.4_linux_amd64.bz2 &&\
    chmod +x restic_0.16.4_linux_amd64 &&\
    mv restic_0.16.4_linux_amd64 /usr/local/bin/restic

#nginx
RUN apt install -y nginx
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/conf.d/* /etc/nginx/conf.d/

# MailHog
RUN wget https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_amd64 &&\
    chmod +x MailHog_linux_amd64 && mv MailHog_linux_amd64 /usr/local/bin/mailhog

#mhsendmail
RUN wget https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 &&\
    chmod +x mhsendmail_linux_amd64 && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail

#supervisor
COPY ./supervisor/conf.d/* /etc/supervisor/conf.d/
COPY ./supervisor/supervisord.conf /etc/supervisor/supervisord.conf

RUN apt-get -y dist-upgrade && apt-get clean

#configs
COPY ./user/* /root/

#workspace
RUN mkdir -p /workspace/app
WORKDIR /workspace/app
COPY ./workspace/app/* ./

EXPOSE 80
EXPOSE 443
EXPOSE 1025
EXPOSE 5173
EXPOSE 8025
EXPOSE 9000
EXPOSE 9001

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]


