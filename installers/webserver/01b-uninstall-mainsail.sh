#!/usr/bin/bash

set -e

MAINSAIL_DIR="/var/www/mainsail.local"

echo "=== Mainsail Perfect Uninstall ==="
echo "This will completely remove all Mainsail components from your system."
echo "Directory to be removed: $MAINSAIL_DIR"
read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo "Stopping and disabling services..."
# Stop services first
sudo systemctl stop klipper.service 2>/dev/null || echo "Klipper service not running"
sudo systemctl stop moonraker.service 2>/dev/null || echo "Moonraker service not running"
sudo systemctl stop ustreamer.service 2>/dev/null || echo "Ustreamer service not running"

# Disable services
sudo systemctl disable klipper.service 2>/dev/null || echo "Klipper service not enabled"
sudo systemctl disable moonraker.service 2>/dev/null || echo "Moonraker service not enabled"
sudo systemctl disable ustreamer.service 2>/dev/null || echo "Ustreamer service not enabled"

echo "Removing systemd service files..."
sudo rm -f /etc/systemd/system/klipper.service
sudo rm -f /etc/systemd/system/moonraker.service
sudo rm -f /etc/systemd/system/ustreamer.service

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Removing nginx configuration..."
sudo rm -f /etc/nginx/sites-enabled/mainsail.conf
sudo rm -f /etc/nginx/sites-available/mainsail.conf

echo "Removing SSL certificates..."
sudo rm -f /etc/ssl/certs/mainsail.local.pem
sudo rm -f /etc/ssl/private/mainsail.local-key.pem
sudo rm -f /etc/ssl/nginx/mainsail.local.pem
sudo rm -f /etc/ssl/nginx/mainsail.local-key.pem

echo "Removing mainsail.local from /etc/hosts..."
sudo sed -i '/mainsail.local/d' /etc/hosts

echo "Removing www-data from dialout and video groups..."
sudo gpasswd -d www-data dialout 2>/dev/null || echo "www-data not in dialout group"
sudo gpasswd -d www-data video 2>/dev/null || echo "www-data not in video group"

echo "Removing PolicyKit rules..."
# Remove moonraker PolicyKit rules
sudo rm -f /etc/polkit-1/rules.d/moonraker.rules
sudo rm -f /usr/share/polkit-1/rules.d/moonraker.rules

echo "Removing main directory structure..."
if [ -d "$MAINSAIL_DIR" ]; then
    sudo rm -rf "$MAINSAIL_DIR"
    echo "Removed $MAINSAIL_DIR"
else
    echo "$MAINSAIL_DIR does not exist"
fi

echo "Removing mkcert certificates from user CA..."
# Remove the local CA certificate if it exists
if command -v mkcert &> /dev/null && [ -d "$HOME/.local/share/mkcert" ]; then
    echo "Uninstalling mkcert local CA..."
    mkcert -uninstall || echo "mkcert CA uninstall failed or not needed"
fi

echo "Cleaning up package dependencies (optional)..."
echo "The following packages were installed and can be removed if not needed elsewhere:"
echo "  python3-virtualenv python3-dev libffi-dev build-essential libncurses-dev"
echo "  avrdude gcc-avr binutils-avr avr-libc stm32flash dfu-util libnewlib-arm-none-eabi"
echo "  gcc-arm-none-eabi binutils-arm-none-eabi libusb-1.0-0 libusb-1.0-0-dev"
echo "  libopenjp2-7 python3-libgpiod curl libcurl4-openssl-dev libssl-dev liblmdb-dev"
echo "  libsodium-dev zlib1g-dev libjpeg-dev packagekit wireless-tools ustreamer"
echo ""
read -p "Do you want to remove these packages? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing package dependencies..."
    sudo apt remove --auto-remove -y \
        python3-virtualenv python3-dev libffi-dev build-essential libncurses-dev \
        avrdude gcc-avr binutils-avr avr-libc stm32flash dfu-util libnewlib-arm-none-eabi \
        gcc-arm-none-eabi binutils-arm-none-eabi libusb-1.0-0 libusb-1.0-0-dev \
        libopenjp2-7 python3-libgpiod curl libcurl4-openssl-dev libssl-dev liblmdb-dev \
        libsodium-dev zlib1g-dev libjpeg-dev packagekit wireless-tools ustreamer 2>/dev/null || echo "Some packages may not have been installed or are needed by other software"
else
    echo "Keeping package dependencies"
fi

echo "Restarting nginx to apply configuration changes..."
sudo systemctl restart nginx 2>/dev/null || echo "Nginx restart failed or not running"

echo ""
echo "=== Mainsail Uninstall Complete ==="
echo "All Mainsail components have been removed from your system."
echo ""
echo "Manual cleanup notes:"
echo "- If you installed mkcert, you may want to remove it: sudo rm /usr/local/bin/mkcert"
echo "- Check for any remaining files in /tmp related to mainsail/klipper/moonraker"
echo "- Review systemd journal logs if needed: journalctl -u klipper -u moonraker -u ustreamer"