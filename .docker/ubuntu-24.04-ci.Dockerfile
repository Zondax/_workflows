FROM ubuntu:24.04

LABEL org.opencontainers.image.source="https://github.com/zondax/_workflows"
LABEL org.opencontainers.image.description="Zondax Ubuntu 24.04 CI base image"
LABEL org.opencontainers.image.vendor="Zondax"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.title="ubuntu-ci"
LABEL org.opencontainers.image.base.name="ubuntu:24.04"

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install all system packages in a single layer (reduces image size)
# - Base dev tools
# - Tauri/GTK dependencies (webkit2gtk-4.1 with libsoup3 for Ubuntu 24.04)
# - Playwright/Chromium dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    # Base dev tools
    build-essential \
    ca-certificates \
    curl \
    docker.io \
    git \
    jq \
    libssl-dev \
    make \
    pkg-config \
    wget \
    # Tauri/GTK
    libayatana-appindicator3-dev \
    libgtk-3-dev \
    librsvg2-dev \
    libsoup-3.0-dev \
    libwebkit2gtk-4.1-dev \
    patchelf \
    # Playwright/Chromium
    libasound2t64 \
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
    # Playwright full browser support (Firefox/WebKit)
    # Fonts
    fonts-freefont-ttf \
    fonts-ipafont-gothic \
    fonts-liberation \
    fonts-noto-color-emoji \
    fonts-tlwg-loma-otf \
    fonts-unifont \
    fonts-wqy-zenhei \
    xfonts-cyrillic \
    xfonts-encodings \
    xfonts-scalable \
    xfonts-utils \
    # GTK4 for WebKit
    libgtk-4-1 \
    # Multimedia/GStreamer
    ffmpeg \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-bad \
    # Additional libs
    libevent-2.1-7t64 \
    libnotify4 \
    libxss1 \
    libxv1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add Zondax CA certificate
COPY ./.docker/zondax_CA.crt /usr/local/share/ca-certificates/zondax_CA.crt
RUN update-ca-certificates

# Install mise and tools (node, pnpm, rust, playwright via postinstall hook)
COPY ./.docker/mise /tmp/mise
RUN chmod +x /tmp/mise/install.sh && /tmp/mise/install.sh

# Environment for mise
ENV PATH="/root/.local/share/mise/shims:${PATH}"
ENV PLAYWRIGHT_BROWSERS_PATH="/root/.cache/ms-playwright"
