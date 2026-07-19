#!/usr/bin/env bash
set -euo pipefail

# Log all output
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

echo "========== Starting EC2 User Data =========="

NODE_MAJOR_VERSION=22

echo "Updating package index..."
apt-get update -y

echo "Installing prerequisites..."
apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    software-properties-common \
    apt-transport-https

echo "Adding NodeSource repository..."
curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR_VERSION}.x | bash -

echo "Installing Node.js..."
apt-get install -y nodejs

echo "Installing PM2..."
npm install -g pm2

echo "Installing Nginx..."
apt-get install -y nginx

echo "Enabling and starting Nginx..."
systemctl enable nginx
systemctl start nginx

echo "Installing Certbot..."
apt-get install -y certbot python3-certbot-nginx

echo "========== Installed Versions =========="
echo "Node.js : $(node --version)"
echo "npm      : $(npm --version)"
echo "PM2      : $(pm2 --version)"
echo "Nginx    : $(nginx -v 2>&1)"
echo "Certbot  : $(certbot --version)"

echo "========== User Data Completed Successfully =========="
