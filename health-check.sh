#!/usr/bin/env bash
# Health Check Script for Privacy Server

set -u

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "=== System Health ==="
uptime -p
echo "Memory:"
free -h | grep Mem
echo "Disk:"
df -h / | tail -1

echo -e "\n=== Services ==="
services=("wg-quick@wg0" "sshd" "nftables" "fail2ban")
for s in "${services[@]}"; do
    if systemctl is-active --quiet "$s"; then
        echo -e "${GREEN}[OK]${NC} $s is running"
    else
        echo -e "${RED}[FAIL]${NC} $s is NOT running"
    fi
done

echo -e "\n=== Containers ==="
if podman ps | grep -q adguardhome; then
    echo -e "${GREEN}[OK]${NC} AdGuard Home container is running"
else
    echo -e "${RED}[FAIL]${NC} AdGuard Home container is NOT running"
fi

if podman ps | grep -q unbound; then
    echo -e "${GREEN}[OK]${NC} Unbound container is running"
else
    echo -e "${RED}[FAIL]${NC} Unbound container is NOT running"
fi

echo -e "\n=== DNS Resolution Test ==="
if dig +short @127.0.0.1 -p 3000 google.com > /dev/null; then
    echo -e "${GREEN}[OK]${NC} AdGuard Home is resolving DNS"
else
    echo -e "${RED}[FAIL]${NC} AdGuard Home failed to resolve DNS"
fi

if dig +short @127.0.0.1 -p 5335 google.com > /dev/null; then
    echo -e "${GREEN}[OK]${NC} Unbound is resolving DNS"
else
    echo -e "${RED}[FAIL]${NC} Unbound failed to resolve DNS"
fi
