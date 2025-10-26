#!/usr/bin/env bash
set -euo pipefail
# Credits to unsung hero @pablos123

echo "Installing Nerd Fonts..."

fonts_path="/usr/share/fonts"
font="JetBrainsMono"

sudo mkdir -p "${fonts_path}/${font}Nerd"

echo "Downloading ${font} Nerd Font..."
wget -O "/tmp/${font}Nerd.tar.xz" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.tar.xz"
sudo tar -xf "/tmp/${font}Nerd.tar.xz" -C "${fonts_path}/${font}Nerd"
rm -f "/tmp/${font}Nerd.tar.xz"

echo "Refreshing font cache..."
sudo fc-cache -f -v

echo "Nerd Fonts installed successfully"
