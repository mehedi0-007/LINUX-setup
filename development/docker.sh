#!/usr/bin/env bash

set -euo pipefail

echo "========================================"
echo " Docker Setup"
echo "========================================"

if command -v docker >/dev/null 2>&1; then
    echo "[Docker] Already installed:"
    docker --version
else
    echo "[Docker] Installing Docker..."

    sudo apt update
    sudo apt install -y \
        ca-certificates \
        curl \
        gnupg

    sudo install -m 0755 -d /etc/apt/keyrings

    if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
        sudo curl -fsSL \
            https://download.docker.com/linux/ubuntu/gpg \
            -o /etc/apt/keyrings/docker.asc

        sudo chmod a+r /etc/apt/keyrings/docker.asc
    fi

    . /etc/os-release

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      ${UBUNTU_CODENAME} stable" |
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update

    sudo apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
fi

echo
echo "[Docker] Configuring user access..."

if ! getent group docker >/dev/null; then
    sudo groupadd docker
fi

if ! id -nG "$USER" | grep -qw docker; then
    sudo usermod -aG docker "$USER"
    echo
    echo "[Docker] Added $USER to the docker group."
    echo "[Docker] Log out and back in for the group change to take effect."
fi

echo
echo "[Docker] Verification:"
docker --version || true
docker compose version || true

echo
echo "[Docker] Setup complete."
