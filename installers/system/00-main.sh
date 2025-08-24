#!/usr/bin/env bash
set -euo pipefail

echo "Installing applications..."

sudo apt-get update

sudo apt-get install -y \
    wayland-utils dbus-user-session seatd systemd-container mesa-vulkan-drivers \
    sway swaybg sway-notification-center swaylock waybar wofi swappy grim slurp wl-clipboard \
    fonts-font-awesome \
    locales locales-all \
    greetd \
    polkitd pkexec lxpolkit \
    pipewire pipewire-audio-client-libraries pipewire-pulse wireplumber pavucontrol \
    libspa-0.2-bluetooth libspa-0.2-libcamera \
    xdg-user-dirs \
    bluez blueman \
    network-manager-gnome \
    ffmpeg mpv \
    thunar gvfs gvfs-backends thunar-archive-plugin thunar-volman file-roller viewnior mousepad \
    gawk unzip curl ripgrep htop direnv cowsay fortune-mod \
    tmux foot mycli \
    network-manager systemd-resolved openvpn-systemd-resolved network-manager-openvpn

echo "Enabling NetworkManager in favour of dhcpcd and wpa_supplicant..."
sudo systemctl stop dhcpcd wpa_supplicant 2>/dev/null || true
sudo systemctl disable dhcpcd wpa_supplicant 2>/dev/null || true
sudo systemctl enable NetworkManager systemd-resolved
sudo systemctl start NetworkManager systemd-resolved

echo "Enabling seatd service..."
sudo systemctl start seatd
sudo systemctl enable seatd

echo "Adding user to render group..."
sudo gpasswd -a "$USER" render
