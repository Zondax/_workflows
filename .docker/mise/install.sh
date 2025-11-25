#!/bin/bash
# Mise and tooling installation script for Zondax base images
set -euo pipefail

# Pin mise version for reproducible builds
MISE_VERSION="${MISE_VERSION:-latest}"

# Install mise (MISE_VERSION can be set to pin a specific version)
curl -fsSL https://mise.run | MISE_VERSION=$MISE_VERSION sh
mv /root/.local/bin/mise /usr/local/bin/mise
chmod +x /usr/local/bin/mise

# Setup for the zondax user
MISE_DATA_DIR="/home/zondax/.local/share/mise"
MISE_CONFIG_DIR="/home/zondax/.config/mise"

mkdir -p "$MISE_DATA_DIR" "$MISE_CONFIG_DIR"
cp /tmp/mise/config.toml "$MISE_CONFIG_DIR/config.toml"
chown -R zondax:zondax /home/zondax/.local /home/zondax/.config

# Switch to zondax user and install tools (postinstall hook runs automatically)
su - zondax -c '
  export PATH="/usr/local/bin:$PATH"
  mise trust --all
  mise install
'

# Cleanup build artifacts and caches to reduce image size
rm -rf /tmp/mise
rm -rf /home/zondax/.cache/pnpm
rm -rf /home/zondax/.npm/_cacache
rm -rf /root/.local
