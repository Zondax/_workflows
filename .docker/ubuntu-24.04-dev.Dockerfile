FROM ubuntu:24.04

LABEL org.opencontainers.image.source="https://github.com/zondax/_workflows"
LABEL org.opencontainers.image.description="Zondax Ubuntu 24.04 development base image"

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

# Install Tauri/GTK dependencies (Tauri v2 compatible)
# Note: Ubuntu 24.04 uses webkit2gtk-4.1 with libsoup3 (not 4.0 with libsoup2)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libayatana-appindicator3-dev \
    libgtk-3-dev \
    librsvg2-dev \
    libsoup-3.0-dev \
    libwebkit2gtk-4.1-dev \
    patchelf \
    && rm -rf /var/lib/apt/lists/*

# Install Playwright system dependencies (Chromium)
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    && rm -rf /var/lib/apt/lists/*

# Add Zondax CA certificate
COPY ./.docker/zondax_CA.crt /usr/local/share/ca-certificates/zondax_CA.crt
RUN update-ca-certificates

# Non-root user (consistent with alpine base)
RUN groupadd --system --gid 65532 zondax && \
    useradd --system --uid 65532 --gid zondax --shell /bin/bash --create-home zondax

# Install mise and tools (node, pnpm, playwright)
COPY ./.docker/mise /tmp/mise
RUN chmod +x /tmp/mise/install.sh && /tmp/mise/install.sh

# Environment for mise
ENV PATH="/home/zondax/.local/share/mise/shims:${PATH}"
ENV PLAYWRIGHT_BROWSERS_PATH="/home/zondax/.cache/ms-playwright"

# Default to non-root user
USER zondax
WORKDIR /home/zondax
