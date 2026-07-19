#!/usr/bin/env bash
set -euo pipefail

# Log everything
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

echo "========== Starting Docker Installation =========="

echo "Updating package index..."
apt-get update -y

echo "Installing prerequisites..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg

echo "Creating Docker keyring directory..."
install -m 0755 -d /etc/apt/keyrings

echo "Downloading Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating package index..."
apt-get update -y

echo "Installing Docker..."
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "Enabling Docker service..."
systemctl enable docker
systemctl start docker

# Optional: Allow the default Ubuntu user to run Docker without sudo
if id "ubuntu" &>/dev/null; then
    usermod -aG docker ubuntu
fi

echo "========== Installed Versions =========="
docker --version
docker compose version

echo "========== Docker Installation Completed =========="
