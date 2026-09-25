#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " Linux Machine Configuration"
echo "========================================"

if [[ ! -f /etc/os-release ]]; then
    echo "ERROR: Cannot determine operating system."
    exit 1
fi

source /etc/os-release

if [[ "$ID" != "ubuntu" ]]; then
    echo "ERROR: This configuration is intended for Ubuntu."
    exit 1
fi

echo
echo "Detected: $PRETTY_NAME"

echo
echo "[1/5] Desktop packages..."
"$CONFIG_DIR/desktop/install.sh"

echo
echo "[2/5] Desktop configuration..."
"$CONFIG_DIR/desktop/configure.sh"

echo
echo "[3/5] Development environment..."
"$CONFIG_DIR/development/install.sh"

echo
echo "[4/5] Shell environment..."
"$CONFIG_DIR/shell/install.sh"

echo
echo "[5/5] Git configuration..."
"$CONFIG_DIR/git/configure.sh"

echo
echo "========================================"
echo " Machine configuration complete"
echo "========================================"
