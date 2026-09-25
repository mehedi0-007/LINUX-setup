#!/usr/bin/env bash

set -euo pipefail

echo "========================================"
echo " VS Code Setup"
echo "========================================"

if command -v code >/dev/null 2>&1; then
    echo "[VS Code] Already installed:"
    code --version | head -n1
    exit 0
fi

echo "[VS Code] Installing Microsoft repository..."

sudo apt update
sudo apt install -y wget gpg apt-transport-https

wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null

sudo chmod a+r /etc/apt/keyrings/packages.microsoft.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt update
sudo apt install -y code

echo
echo "[VS Code] Installed:"
code --version | head -n1

echo
echo "[VS Code] Setup complete."
