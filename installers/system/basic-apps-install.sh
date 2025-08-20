#!/usr/bin/env bash

sudo apt-get update

# PipeWire
sudo apt-get install -y pipewire pipewire-audio-client-libraries pipewire-pulse wireplumber pavucontrol

# Bluetooth
sudo apt-get install -y bluez blueman

# Archive and compression tools
sudo apt-get install -y unzip

# System utilities
sudo apt-get install -y locales-all gawk

# Media tools
sudo apt-get install -y ffmpeg mpv

# Entertainment
sudo apt-get install -y fortune cowsay fortune-mod

# Development tools
sudo apt-get install -y direnv shellcheck curl ripgrep

# Display manager
sudo apt-get install -y greetd
