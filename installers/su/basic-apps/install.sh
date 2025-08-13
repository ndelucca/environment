#!/usr/bin/env bash

apt update

# PipeWire
apt install pipewire pipewire-audio-client-libraries pipewire-pulse wireplumber pavucontrol

# Bluetooth
apt install bluez blueman
