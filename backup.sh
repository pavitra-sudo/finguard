#!/usr/bin/env bash
# Backup Script for Privacy Server

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)." 
   exit 1
fi

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$BASE_DIR/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/privacy_server_backup_$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "Stopping containers for consistent backup..."
podman-compose -f "$BASE_DIR/podman/podman-compose.yml" stop

echo "Creating backup..."
tar -czf "$BACKUP_FILE" \
    -C "$BASE_DIR" \
    configs/ \
    podman/ \
    -C / \
    etc/wireguard/ \
    etc/nftables.conf \
    etc/fail2ban/jail.local \
    etc/sysctl.d/99-privacy-server.conf \
    etc/ssh/sshd_config

echo "Starting containers..."
podman-compose -f "$BASE_DIR/podman/podman-compose.yml" start

echo "Backup created at $BACKUP_FILE"

ls -tp "$BACKUP_DIR"/privacy_server_backup_*.tar.gz | grep -v '/$' | tail -n +8 | xargs -I {} rm -- {}
echo "Old backups cleaned up. (Kept latest 7)"
