#!/usr/bin/env bash
set -euo pipefail

# Log all output to a file and the system journal
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

echo "========== Starting EC2 Bootstrap =========="

NODE_MAJOR_VERSION=22

###############################################################################
# Update system and install prerequisites
###############################################################################

echo "Updating package index..."
apt-get update -y

echo "Installing prerequisites..."
apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    software-properties-common \
    apt-transport-https

###############################################################################
# Install Docker & Docker Compose
###############################################################################

echo "Installing Docker repository..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| tee /etc/apt/sources.list.d/docker.list >/dev/null

apt-get update -y

echo "Installing Docker Engine..."

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable docker
systemctl start docker

# Allow the default Ubuntu user to run Docker without sudo
if id ubuntu &>/dev/null; then
    usermod -aG docker ubuntu
fi

###############################################################################
# Install Node.js & PM2
###############################################################################

echo "Installing NodeSource repository..."

curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR_VERSION}.x | bash -

echo "Installing Node.js..."

apt-get install -y nodejs

echo "Installing PM2..."

npm install -g pm2

###############################################################################
# Install Nginx & Certbot
###############################################################################

echo "Installing Nginx and Certbot..."

apt-get install -y \
    nginx \
    certbot \
    python3-certbot-nginx

systemctl enable nginx
systemctl start nginx

###############################################################################
# Display installed versions
###############################################################################

echo
echo "========== Installed Versions =========="

echo "Docker      : $(docker --version)"
echo "Compose     : $(docker compose version)"
echo "Node.js     : $(node --version)"
echo "npm         : $(npm --version)"
echo "PM2         : $(pm2 --version)"
echo "Nginx       : $(nginx -v 2>&1)"
echo "Certbot     : $(certbot --version)"

echo
echo "========== Bootstrap Completed Successfully =========="
