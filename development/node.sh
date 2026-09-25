#!/usr/bin/env bash

set -euo pipefail

NODE_VERSION="24.17.0"
NVM_VERSION="v0.40.3"

echo "========================================"
echo " Node.js Setup"
echo "========================================"

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    echo "[Node] Installing NVM ${NVM_VERSION}..."

    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" \
        | bash
fi

export NVM_DIR="$HOME/.nvm"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    echo "ERROR: NVM installation failed."
    exit 1
fi

# Load NVM into this shell.
source "$NVM_DIR/nvm.sh"

echo "[Node] Installing Node.js ${NODE_VERSION}..."

if ! nvm ls "$NODE_VERSION" >/dev/null 2>&1; then
    nvm install "$NODE_VERSION"
fi

nvm alias default "$NODE_VERSION"
nvm use "$NODE_VERSION"

echo
echo "[Node] Versions:"
node --version
npm --version

echo
echo "[Node] Setup complete."
