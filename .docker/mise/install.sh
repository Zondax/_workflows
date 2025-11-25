#!/bin/bash
# Mise and tooling installation script for Zondax CI base images
set -euo pipefail

# Install mise
# Set MISE_VERSION env var before running to pin a specific version (e.g., MISE_VERSION=2024.11.0)
if [ -n "${MISE_VERSION:-}" ]; then
  curl -fsSL https://mise.run | MISE_VERSION="$MISE_VERSION" sh
else
  curl -fsSL https://mise.run | sh
fi
mv /root/.local/bin/mise /usr/local/bin/mise
chmod +x /usr/local/bin/mise

# Setup mise config for root
MISE_DATA_DIR="/root/.local/share/mise"
MISE_CONFIG_DIR="/root/.config/mise"

mkdir -p "$MISE_DATA_DIR" "$MISE_CONFIG_DIR"
cp /tmp/mise/config.toml "$MISE_CONFIG_DIR/config.toml"

# Install tools (postinstall hook runs automatically)
mise trust --all
mise install

# Cleanup build artifacts and caches to reduce image size
rm -rf /tmp/mise
rm -rf /root/.cache/pnpm
rm -rf /root/.npm/_cacache
