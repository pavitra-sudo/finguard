#!/usr/bin/env bash
# WireGuard Client Config Generator

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)." 
   exit 1
fi

CLIENT_NAME=$1
if [ -z "$CLIENT_NAME" ]; then
    echo "Usage: $0 <client-name>"
    exit 1
fi

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$BASE_DIR/configs/wireguard/clients/$CLIENT_NAME"
mkdir -p "$CLIENT_DIR"

SERVER_PUBKEY=$(cat /etc/wireguard/publickey)
ENDPOINT_IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')
ENDPOINT_PORT="51820"

LAST_IP=$(grep -oP 'AllowedIPs = 10.10.0.\K[0-9]+' /etc/wireguard/wg0.conf | sort -n | tail -1 || echo "1")
NEXT_IP=$((LAST_IP + 1))
CLIENT_IP="10.10.0.$NEXT_IP/32"

wg genkey | tee "$CLIENT_DIR/privatekey" | wg pubkey > "$CLIENT_DIR/publickey"
CLIENT_PRIVKEY=$(cat "$CLIENT_DIR/privatekey")
CLIENT_PUBKEY=$(cat "$CLIENT_DIR/publickey")

cat > "$CLIENT_DIR/$CLIENT_NAME.conf" << EOF
[Interface]
PrivateKey = $CLIENT_PRIVKEY
Address = 10.10.0.$NEXT_IP/24
DNS = 10.10.0.1
MTU = 1420

[Peer]
PublicKey = $SERVER_PUBKEY
Endpoint = $ENDPOINT_IP:$ENDPOINT_PORT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

cat >> /etc/wireguard/wg0.conf << EOF

# Client: $CLIENT_NAME
[Peer]
PublicKey = $CLIENT_PUBKEY
AllowedIPs = $CLIENT_IP
EOF

wg syncconf wg0 <(wg-quick strip wg0)

echo "Client $CLIENT_NAME added with IP 10.10.0.$NEXT_IP"
echo "--- QR Code ---"
qrencode -t ansiutf8 < "$CLIENT_DIR/$CLIENT_NAME.conf"
echo "Config saved to $CLIENT_DIR/$CLIENT_NAME.conf"
