#!/usr/bin/env bash

set -euo pipefail

FONT_NAME="JetBrainsMono"
FONT_DIR="/usr/local/share/fonts/${FONT_NAME}Nerd"
TMP_PATH="$(mktemp)"

echo "Installing ${FONT_NAME} Nerd Font system-wide..."

sudo mkdir -p "$FONT_DIR"

echo "Downloading ${FONT_NAME} Nerd Font..."
curl -fsSL -o "$TMP_PATH" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.tar.xz"

echo "Extracting to ${FONT_DIR}..."
sudo tar -xf "$TMP_PATH" -C "$FONT_DIR"
rm -f "$TMP_PATH"

echo "Restoring SELinux context..."
sudo restorecon -R "$FONT_DIR"

echo "Updating font cache..."
sudo fc-cache -f "$FONT_DIR"

sudo cp ./02-wallpaper.png /usr/share/backgrounds/wallpaper.png
