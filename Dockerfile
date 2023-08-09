FROM python:3-bullseye

LABEL maintainer="Vasilii Shvakin <vasilii.shvakin@gmail.com>"

RUN apt-get update && apt-get -y dist-upgrade && apt-get -y install bind9-dnsutils colordiff dnsutils ffmpeg git gnupg htop mc ssh sudo tmux links2

RUN pip3 install --upgrade pip

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt && rm requirements.txt

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
    && code-server --install-extension dbaeumer.vscode-eslint \
    && code-server --install-extension DEVSENSE.composer-php-vscode \
    && code-server --install-extension esbenp.prettier-vscode \
    && code-server --install-extension ms-azuretools.vscode-docker \
    && code-server --install-extension rvest.vs-code-prettier-eslint \
    && code-server --install-extension sleistner.vscode-fileutils \
    && code-server --install-extension streetsidesoftware.code-spell-checker \
    && code-server --install-extension ms-python.python

RUN apt-get -y dist-upgrade && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
