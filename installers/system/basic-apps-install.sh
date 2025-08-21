#!/usr/bin/env bash
set -euo pipefail

echo "Installing basic applications..."

sudo apt-get update

# Install all packages in one command for efficiency
sudo apt-get install -y \
    locales-all \
    greetd \
    polkitd pkexec lxpolkit \
    pipewire pipewire-audio-client-libraries pipewire-pulse wireplumber pavucontrol \
    libspa-0.2-bluetooth libspa-0.2-libcamera \
    bluez blueman \
    network-manager-gnome \
    ffmpeg mpv \
    thunar gvfs gvfs-backends thunar-archive-plugin thunar-volman file-roller viewnior mousepad \
    gawk unzip curl ripgrep htop direnv cowsay fortune-mod

echo "Basic applications installed successfully"
