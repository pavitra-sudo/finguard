# Privacy Server Platform

A self-hosted, privacy-focused personal server platform designed for Raspberry Pi 3B+ running Fedora. This repository is designed to be cloned and run "out of the box".

## Architecture Overview

This platform provides a secure tunnel to your home network while blocking ads and trackers, and resolving DNS queries securely and privately without relying on third-party upstream providers.

- **WireGuard**: Provides a high-performance, modern VPN tunnel directly into the Raspberry Pi.
- **AdGuard Home**: Acts as the primary DNS server for VPN clients, filtering out ads, malware, and trackers.
- **Unbound**: A recursive DNS resolver that queries root DNS servers directly, validating responses with DNSSEC.

**Flow**: `Client -> WireGuard (51820/UDP) -> AdGuard Home (Container) -> Unbound (Container) -> Root DNS`

## Installation Guide

1. Clone this repository directly onto your Raspberry Pi:
   ```bash
   git clone <repo-url> /home/pi/finguard
   cd /home/pi/finguard
   ```
2. Make scripts executable:
   ```bash
   chmod +x *.sh
   ```
3. Run the installer:
   ```bash
   sudo ./install.sh
   ```
4. Access the AdGuard Home web interface at `http://<PI_IP>:3000` (Default Login: admin / admin). **Change this immediately!**

## Managing VPN Clients

To add a new device (like your phone) so it can connect from anywhere in the world:

```bash
sudo ./configure.sh my-iphone
```
This will generate a `.conf` file and display a QR code on the terminal. Open the WireGuard app on your phone and scan the QR code.

## Backup & Restore

**Backup**: `sudo ./backup.sh` (Keeps last 7 backups in `backups/` dir)
**Restore**: `sudo ./restore.sh backups/privacy_server_backup_YYYYMMDD_HHMMSS.tar.gz`

## Maintenance Tasks

- **Update System & Containers**: `sudo ./update.sh`
- **Health Check**: `./health-check.sh`
- **Diagnostics**: `sudo ./diagnostics.sh`
