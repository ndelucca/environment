#!/usr/bin/env bash
# Credits to unsung hero @pablos123

set -euo pipefail

echo "Installing Nerd Fonts..."

fonts_path="/usr/share/fonts"
font="JetBrainsMono"

# Create fonts directory
sudo mkdir -p "${fonts_path}/${font}Nerd"

# Download and install font
echo "Downloading ${font} Nerd Font..."
wget -O "/tmp/${font}Nerd.tar.xz" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.tar.xz"
sudo tar -xf "/tmp/${font}Nerd.tar.xz" -C "${fonts_path}/${font}Nerd"
rm -f "/tmp/${font}Nerd.tar.xz"

# Refresh font cache
echo "Refreshing font cache..."
sudo fc-cache -f -v

echo "Nerd Fonts installed successfully"
