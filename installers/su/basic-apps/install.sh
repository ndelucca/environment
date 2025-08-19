#!/usr/bin/env bash

apt-get update

# PipeWire
apt-get install -y pipewire pipewire-audio-client-libraries pipewire-pulse wireplumber pavucontrol

# Bluetooth
apt-get install -y bluez blueman

# Archive and compression tools
apt-get install -y unzip

# System utilities
apt-get install -y locales-all gawk

# Media tools
apt-get install -y ffmpeg mpv

# Entertainment
apt-get install -y fortune cowsay fortune-mod

# Development tools
apt-get install -y direnv shellcheck curl ripgrep

# Display manager
apt-get install -y greetd
