#!/usr/bin/env bash

set -euo pipefail

# -----------------------------------------------------------------------------
# Project Paths
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

MAPPING_FILE="$PROJECT_ROOT/deployment/domain-mapping.conf"
NGINX_DIR="$PROJECT_ROOT/deployment/nginx/conf.d"

# -----------------------------------------------------------------------------
# Validate mapping file
# -----------------------------------------------------------------------------

if [[ ! -f "$MAPPING_FILE" ]]; then
    echo "Mapping file not found."
    exit 1
fi

# -----------------------------------------------------------------------------
# Create nginx directory if it doesn't exist
# -----------------------------------------------------------------------------

mkdir -p "$NGINX_DIR"

# -----------------------------------------------------------------------------
# Remove old generated configs
# -----------------------------------------------------------------------------

rm -f "$NGINX_DIR"/*.conf

# -----------------------------------------------------------------------------
# Generate one config per domain
# -----------------------------------------------------------------------------

COUNT=0

while read -r domain tenant; do

    [[ -z "${domain:-}" ]] && continue
    [[ "$domain" =~ ^# ]] && continue

    OUTPUT_FILE="$NGINX_DIR/$domain.conf"

    cat > "$OUTPUT_FILE" <<EOF
server {
    listen 80;

    server_name $domain;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        proxy_pass http://frontend:3000;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    COUNT=$((COUNT + 1))

done < "$MAPPING_FILE"

echo
echo "Generated $COUNT nginx configuration files."
echo "Output directory:"
echo "$NGINX_DIR"
