#!/usr/bin/env bash

apt-get update

# PipeWire
apt-get install -y pipewire pipewire-audio-client-libraries pipewire-pulse wireplumber pavucontrol

# Bluetooth
apt-get install -y bluez blueman

apt-get install -y fortune cowsay

# Development tools
apt-get install -y direnv

# Display manager
apt-get install -y greetd
