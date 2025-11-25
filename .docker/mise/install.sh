#!/bin/bash
# Mise and tooling installation script for Zondax base images
set -euo pipefail

# Install mise
curl -fsSL https://mise.run | sh
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

# Cleanup
rm -rf /tmp/mise
