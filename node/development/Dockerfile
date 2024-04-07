FROM node:20-bullseye

LABEL maintainer="Vasilii Shvakin <vasilii.shvakin@gmail.com>"

RUN apt-get update && apt-get -y dist-upgrade && apt-get -y install bind9-dnsutils ca-certificates colordiff curl ffmpeg git gnupg graphviz htop imagemagick iputils-ping links2 mc moreutils nano procps ssh sudo tmux wget

RUN npm install -g npm@latest

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

RUN apt-get -y dist-upgrade && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
