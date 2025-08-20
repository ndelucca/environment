#!/usr/bin/bash
set -euo pipefail

echo "Installing Wayland components..."

# Install Wayland dependencies
sudo apt-get update
sudo apt-get install -y \
    wl-clipboard \
    wayland-utils \
    dbus-user-session \
    seatd \
    systemd-container \
    xdg-user-dirs \
    mesa-vulkan-drivers

# Enable seatd service
echo "Enabling seatd service..."
sudo systemctl start seatd
sudo systemctl enable seatd

# Add current user to render group for GPU access
echo "Adding user to render group..."
sudo gpasswd -a "$USER" render

echo "Wayland components installed successfully"
echo "Please log out and back in for group changes to take effect"

