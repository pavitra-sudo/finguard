#!/usr/bin/env bash
# Update Script for Privacy Server

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)." 
   exit 1
fi

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Updating Host OS Packages ==="
apt-get update
apt-get upgrade -y
apt-get autoremove -y

echo "=== Updating Podman Containers ==="
cd "$BASE_DIR/podman"
podman-compose pull
podman-compose up -d --remove-orphans
podman image prune -a -f

echo "=== Update Complete ==="
