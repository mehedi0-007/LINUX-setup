#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "========================================"
echo " Development Environment Setup"
echo "========================================"

echo
echo "[1/4] Updating APT..."
sudo apt update

echo
echo "[2/4] Installing development packages..."

if [[ -f "$CONFIG_DIR/development/apt.txt" ]]; then
    sudo xargs -a "$CONFIG_DIR/development/apt.txt" \
        apt-get install -y
else
    echo "ERROR: development/apt.txt not found."
    exit 1
fi

echo
echo "[3/4] Verifying core tools..."

commands=(
    gcc
    g++
    make
    git
    python3
    cmake
    ninja
    gdb
    valgrind
    strace
    htop
    tree
    jq
    rg
    gh
)

for cmd in "${commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  ✓ $cmd"
    else
        echo "  ✗ $cmd"
    fi
done

echo
echo
echo "[Node.js] Setting up Node.js..."
"$CONFIG_DIR/development/node.sh"
echo
echo "[Docker] Setting up Docker..."
"$CONFIG_DIR/development/docker.sh"

echo
echo "[VS Code] Setting up VS Code..."
"$CONFIG_DIR/development/vscode.sh"
