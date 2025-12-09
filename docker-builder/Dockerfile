FROM debian:trixie-slim
ENV DEBIAN_FRONTEND=noninteractive

# Upgrade packages and install essentials
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    ca-certificates \
    curl \
    # Build tools
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    git \
    # SSH server
    openssh-server \
    # Process supervisor
    supervisor \
    # System utilities
    procps \
    iputils-ping \
    fping \
    net-tools \
    telnet \
    # Development utilities
    vim \
    nano \
    mc \
    htop \
    tmux \
    tree \
    # Archive tools
    unzip \
    zip \
    rsync \
    # Data processing tools
    jq \
    yq \
    pv \
    # Network utilities
    bind9-dnsutils \
    wget \
    links2 \
    # Additional utilities
    moreutils \
    graphviz \
    colordiff \
    sudo \
    software-properties-common \
    man \
    bash-completion \
    most \
    tini \
    patch \
    strace \
    tig \
    && rm -rf /var/lib/apt/lists/*

# Install Docker and Docker Compose
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

# Install Docker Compose (standalone binary for convenience)
RUN DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")') && \
    curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Install Docker Buildx (for multi-platform builds)
RUN mkdir -p /usr/local/lib/docker/cli-plugins && \
    BUILDX_VERSION=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | grep -Po '"tag_name": "\K.*?(?=")') && \
    curl -SL "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64" -o /usr/local/lib/docker/cli-plugins/docker-buildx && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx

# Prepare SSH for root login
RUN ssh-keygen -A && \
    mkdir -p /var/run/sshd /root/.ssh && \
    touch /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

# Create log directories
RUN mkdir -p /var/log/supervisor /var/log/docker

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Expose SSH port
EXPOSE 22

# Healthcheck - verify supervisor is running and managing both services
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD supervisorctl status dockerd | grep -q RUNNING && \
        supervisorctl status sshd | grep -q RUNNING || exit 1

WORKDIR /root
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
