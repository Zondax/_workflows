FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/zondax/_workflows"
LABEL org.opencontainers.image.description="Zondax Ubuntu 22.04 development base image"

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install security updates and base dev tools
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    jq \
    libssl-dev \
    make \
    pkg-config \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Tauri/GTK dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    javascriptcoregtk-4.1-dev \
    libayatana-appindicator3-dev \
    libgtk-3-dev \
    librsvg2-dev \
    libsoup-3.0-dev \
    libwebkit2gtk-4.1-dev \
    patchelf \
    && rm -rf /var/lib/apt/lists/*

# Add Zondax CA certificate
COPY ./.docker/zondax_CA.crt /usr/local/share/ca-certificates/zondax_CA.crt
RUN update-ca-certificates

# Non-root user (consistent with alpine base)
RUN groupadd --system --gid 65532 zondax && \
    useradd --system --uid 65532 --gid zondax --shell /bin/bash --create-home zondax

# Default to non-root user
USER zondax
WORKDIR /home/zondax
