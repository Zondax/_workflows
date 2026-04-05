FROM ubuntu:22.04 AS ubuntu-22-base

LABEL org.opencontainers.image.source="https://github.com/zondax/_workflows"
LABEL org.opencontainers.image.description="Zondax Ubuntu 22.04 CI base image"
LABEL org.opencontainers.image.vendor="Zondax"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.title="ubuntu-ci"
LABEL org.opencontainers.image.base.name="ubuntu:22.04"

ENV DEBIAN_FRONTEND=noninteractive
ARG MISE_VERSION=2026.4.3

# Shared tooling used by all Ubuntu 22.04 CI variants.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    docker.io \
    file \
    git \
    jq \
    libssl-dev \
    make \
    pkg-config \
    wget \
    zstd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./.docker/zondax_CA.crt /usr/local/share/ca-certificates/zondax_CA.crt
RUN update-ca-certificates

COPY ./.docker/mise /tmp/mise
RUN chmod +x /tmp/mise/install.sh && MISE_VERSION="$MISE_VERSION" /tmp/mise/install.sh

ENV PATH="/root/.local/share/mise/shims:${PATH}"
ENV PLAYWRIGHT_BROWSERS_PATH="/root/.cache/ms-playwright"

FROM ubuntu-22-base AS ubuntu-22-tauri

# Tauri desktop build and headless e2e dependencies without Playwright browser extras.
RUN apt-get update && apt-get install -y --no-install-recommends \
    javascriptcoregtk-4.1-dev \
    libayatana-appindicator3-dev \
    libgtk-3-dev \
    librsvg2-dev \
    libsoup-3.0-dev \
    libwebkit2gtk-4.1-dev \
    libxdo-dev \
    patchelf \
    xvfb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM ubuntu-22-tauri AS ubuntu-22-playwright

# Browser automation extras layered on top of the Tauri-capable image.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libevent-2.1-7 \
    libgbm1 \
    libglib2.0-0 \
    libgtk-4-1 \
    libnotify4 \
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
    libxss1 \
    libxv1 \
    ffmpeg \
    fonts-freefont-ttf \
    fonts-ipafont-gothic \
    fonts-liberation \
    fonts-noto-color-emoji \
    fonts-tlwg-loma-otf \
    fonts-unifont \
    fonts-wqy-zenhei \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-bad \
    xfonts-cyrillic \
    xfonts-encodings \
    xfonts-scalable \
    xfonts-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
