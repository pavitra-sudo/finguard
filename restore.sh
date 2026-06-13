#!/usr/bin/env bash
# Restore Script for Privacy Server

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)." 
   exit 1
fi

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "${1:-}" ]; then
    echo "Usage: $0 <path-to-backup-tar-gz>"
    echo "Available backups:"
    ls -l "$BASE_DIR/backups/"
    exit 1
fi

BACKUP_FILE="$1"
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found."
    exit 1
fi

echo "Stopping services..."
podman-compose -f "$BASE_DIR/podman/podman-compose.yml" stop || true
systemctl stop wg-quick@wg0 || true

echo "Restoring from $BACKUP_FILE..."
tar -xzf "$BACKUP_FILE" -C /

echo "Restarting services..."
systemctl daemon-reload
systemctl restart wg-quick@wg0
systemctl restart nftables
systemctl restart fail2ban
systemctl restart sshd
podman-compose -f "$BASE_DIR/podman/podman-compose.yml" start

echo "Restore complete. Please run health-check.sh to verify."
