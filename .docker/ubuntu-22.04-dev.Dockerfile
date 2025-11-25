FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/zondax/_workflows"
LABEL org.opencontainers.image.description="Zondax Ubuntu 22.04 development base image"

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install all system packages in a single layer (reduces image size)
# - Base dev tools
# - Tauri/GTK dependencies
# - Playwright/Chromium dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    # Base dev tools
    build-essential \
    ca-certificates \
    curl \
    git \
    jq \
    libssl-dev \
    make \
    pkg-config \
    wget \
    # Tauri/GTK
    javascriptcoregtk-4.1-dev \
    libayatana-appindicator3-dev \
    libgtk-3-dev \
    librsvg2-dev \
    libsoup-3.0-dev \
    libwebkit2gtk-4.1-dev \
    patchelf \
    # Playwright/Chromium
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libglib2.0-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libx11-6 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xvfb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add Zondax CA certificate
COPY ./.docker/zondax_CA.crt /usr/local/share/ca-certificates/zondax_CA.crt
RUN update-ca-certificates

# Non-root user with passwordless sudo
RUN apt-get update && apt-get install -y --no-install-recommends sudo \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system --gid 65532 zondax \
    && useradd --system --uid 65532 --gid zondax --shell /bin/bash --create-home zondax \
    && echo "zondax ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/zondax \
    && chmod 0440 /etc/sudoers.d/zondax

# Install mise and tools (node, pnpm, rust, playwright via postinstall hook)
COPY ./.docker/mise /tmp/mise
RUN chmod +x /tmp/mise/install.sh && /tmp/mise/install.sh

# Environment for mise
ENV PATH="/home/zondax/.local/share/mise/shims:${PATH}"
ENV PLAYWRIGHT_BROWSERS_PATH="/home/zondax/.cache/ms-playwright"

# Default to non-root user
USER zondax
WORKDIR /home/zondax
