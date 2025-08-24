# NetworkManager Setup Guide

## Overview
NetworkManager is integrated into the main system installation (00-main.sh). Clean setup with automatic service management.

## What it does (integrated in main installer)
- ✅ Installs NetworkManager + OpenVPN + systemd-resolved
- ✅ Disables conflicting services (dhcpcd, wpa_supplicant)
- ✅ Enables and starts NetworkManager and systemd-resolved services
- ✅ Configures DNS resolution via systemd-resolved automatically

## Usage

### Complete Setup
```bash
# Step 1: Install packages and configure services (includes NetworkManager setup)
sudo ./installers/setup.sh

# Step 2: Deploy configuration files
cd stow-files && sudo ./manage.sh install system

# Step 3: Configure your networks manually
nmcli device wifi list
nmcli device wifi connect "YourWiFiName" password "YourPassword"
```

## Architecture

### Services
- **Disabled**: `dhcpcd`, `wpa_supplicant`
- **Enabled**: `NetworkManager`, `systemd-resolved`

### DNS Resolution
```
NetworkManager → systemd-resolved → DNS servers
```

### Configuration Files
- `stow-files/system/etc/NetworkManager/NetworkManager.conf`
- `stow-files/system/etc/network/interfaces` (minimal)

## Manual WiFi Configuration

### List available networks
```bash
nmcli device wifi list
```

### Connect to WiFi
```bash
nmcli device wifi connect "NetworkName" password "YourPassword"
```

### Create permanent connection
```bash
nmcli connection add type wifi ifname wlp2s0 con-name "MyWiFi" ssid "NetworkName"
nmcli connection modify "MyWiFi" wifi-sec.key-mgmt wpa-psk wifi-sec.psk "YourPassword"
nmcli connection up "MyWiFi"
```

### GUI Configuration
```bash
nm-connection-editor
```

## Useful Commands

### Network Status
```bash
nmcli device status
nmcli connection show
```

### DNS Status
```bash
resolvectl status
systemd-resolve --statistics  # if available
```

### OpenVPN
```bash
nmcli connection import type openvpn file=/path/to/config.ovpn
nmcli connection up "VPN-Connection-Name"
```

## Troubleshooting

### No internet after setup
1. Check services: `systemctl status NetworkManager systemd-resolved`
2. Check devices: `nmcli device status`
3. Connect to WiFi manually (see commands above)
4. Check DNS: `resolvectl status`

### Connection issues
```bash
# Restart NetworkManager
sudo systemctl restart NetworkManager

# Reset connections
nmcli connection reload
```

## Files

### Installer
- NetworkManager setup integrated in `installers/system/00-main.sh` (lines 24-30)

### Configuration (via stow)
- `stow-files/system/etc/NetworkManager/NetworkManager.conf`
- `stow-files/system/etc/network/interfaces`

## Benefits of This Approach

- ✅ **Clean separation**: Installer does infrastructure, user does configuration
- ✅ **No migration complexity**: Start fresh, configure as needed
- ✅ **Predictable**: Same result every time
- ✅ **Debuggable**: Clear responsibilities
- ✅ **Flexible**: User controls their network setup
- ✅ **Maintainable**: Minimal installer logic
