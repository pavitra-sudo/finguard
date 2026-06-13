#!/usr/bin/env bash
# Diagnostics Script for Privacy Server

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)." 
   exit 1
fi

echo "Gathering diagnostic data..."
REPORT_FILE="/tmp/privacy-server-diag-$(date +%s).txt"

{
    echo "=== DATE ==="
    date
    echo -e "\n=== UPTIME & LOAD ==="
    uptime
    echo -e "\n=== MEMORY ==="
    free -m
    echo -e "\n=== DISK SPACE ==="
    df -h
    echo -e "\n=== NETWORK INTERFACES ==="
    ip a
    echo -e "\n=== ROUTING TABLE ==="
    ip route
    echo -e "\n=== WIREGUARD STATUS ==="
    wg show
    echo -e "\n=== NFTABLES RULES ==="
    nft list ruleset
    echo -e "\n=== FAIL2BAN STATUS ==="
    fail2ban-client status
    echo -e "\n=== PODMAN CONTAINERS ==="
    podman ps -a
    echo -e "\n=== PODMAN LOGS (ADGUARD) ==="
    podman logs --tail 20 adguardhome
    echo -e "\n=== PODMAN LOGS (UNBOUND) ==="
    podman logs --tail 20 unbound
    echo -e "\n=== SYSTEM JOURNAL (ERRORS) ==="
    journalctl -p 3 -xb --no-pager | tail -n 50
} > "$REPORT_FILE"

echo "Diagnostics saved to $REPORT_FILE"
