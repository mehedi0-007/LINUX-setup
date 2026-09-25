#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "========================================"
echo " Desktop Package Setup"
echo "========================================"

echo
echo "[1/2] Updating APT..."
sudo apt update

echo
echo "[2/2] Installing desktop packages..."

if [[ -f "$CONFIG_DIR/desktop/apt.txt" ]]; then
    sudo xargs -a "$CONFIG_DIR/desktop/apt.txt" apt-get install -y
else
    echo "ERROR: desktop/apt.txt not found."
    exit 1
fi

echo
echo "[Desktop] Package installation complete."
