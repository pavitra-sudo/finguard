#!/usr/bin/env bash
# Install Script for Privacy Server

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)." 
   exit 1
fi

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== System Update and Dependencies ==="
dnf upgrade -y
dnf install -y podman podman-compose wireguard-tools qrencode jq curl nftables fail2ban

echo "=== Applying Sysctl Settings ==="
cp "$BASE_DIR/configs/sysctl/99-privacy-server.conf" /etc/sysctl.d/
sysctl --system

echo "=== Configuring SSH ==="
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak || true
cp "$BASE_DIR/configs/ssh/sshd_config" /etc/ssh/sshd_config
systemctl restart sshd

echo "=== Configuring Fail2ban ==="
cp "$BASE_DIR/configs/fail2ban/jail.local" /etc/fail2ban/
systemctl enable --now fail2ban
systemctl restart fail2ban

echo "=== Configuring nftables ==="
systemctl disable --now firewalld || true
cp "$BASE_DIR/configs/nftables/nftables.conf" /etc/nftables.conf
systemctl enable --now nftables
nft -f /etc/nftables.conf

echo "=== Setting up WireGuard ==="
mkdir -p /etc/wireguard
if [ ! -f /etc/wireguard/privatekey ]; then
    wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
fi

SERVER_PRIVKEY=$(cat /etc/wireguard/privatekey)

cat "$BASE_DIR/configs/wireguard/wg0.conf" | sed "s|<SERVER_PRIVATE_KEY>|$SERVER_PRIVKEY|g" > /etc/wireguard/wg0.conf

systemctl enable --now wg-quick@wg0

echo "=== Starting Podman Services ==="
cd "$BASE_DIR/podman"
mkdir -p "$BASE_DIR/configs/adguard/work"
podman-compose up -d

echo "=== Setup Complete ==="
echo "AdGuard Home is running on http://<pi-ip>:3000 (Login: admin / admin)"
echo "WireGuard is active. Run configure.sh to add clients."
