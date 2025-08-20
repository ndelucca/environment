#!/usr/bin/env bash
set -euo pipefail

echo "Installing basic applications..."

sudo apt-get update

# Install all packages in one command for efficiency
sudo apt-get install -y \
    pipewire pipewire-audio-client-libraries pipewire-pulse wireplumber pavucontrol \
    bluez blueman \
    unzip \
    locales-all gawk \
    ffmpeg mpv \
    fortune cowsay fortune-mod \
    direnv shellcheck curl ripgrep \
    greetd \
    polkitd pkexec lxpolkit \
    nautilus \
    gnome-text-editor \
    eog \
    file-roller \
    htop \
    network-manager-gnome

echo "Basic applications installed successfully"
