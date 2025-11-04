#!/usr/bin/env bash

set -euo pipefail

FROZEN_DIR=$(dirname "$0")
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

echo "Updating system wallpaper"
sudo cp "${FROZEN_DIR}/wallpaper.png" /usr/share/backgrounds/wallpaper.png

echo "SDDM configuration"
echo "Updating sddm wallpaper"
sudo cp /usr/share/backgrounds/default.jxl /usr/share/backgrounds/default.jxl.bak
sudo cp "${FROZEN_DIR}/wallpaper.png" /usr/share/backgrounds/default.jxl

echo "Creating sddm configuration file"
sudo tee /etc/sddm.conf.d/ndelucca.conf > /dev/null <<'EOF'
[Autologin]
# User=ndelucca
# Session=sway
[General]
EnableHiDPI=true
[Theme]
EnableAvatars=false
EOF

echo "Configuring GRUB2"

if [ -d /sys/firmware/efi ]; then
    GRUB_CFG="/boot/efi/EFI/fedora/grub.cfg"
else
    GRUB_CFG="/boot/grub2/grub.cfg"
fi

THEME_DIR="/boot/grub2/themes/breeze"
THEME_FILE="${THEME_DIR}/theme.txt"
TMP_DIR="$(mktemp -d)"
REPO_URL="https://github.com/gustawho/grub2-theme-breeze.git"

if [ ! -f "${THEME_FILE}" ]; then
    sudo git clone --depth=1 "${REPO_URL}" "${TMP_DIR}/repo"
    sudo mkdir -p /boot/grub2/themes
    sudo rm -rf "${THEME_DIR}"
    sudo cp -r "${TMP_DIR}/repo/breeze" "${THEME_DIR}"
else
    echo "Theme already installed at ${THEME_FILE}"
fi

sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"${THEME_FILE}\"" | sudo tee -a /etc/default/grub > /dev/null

if ! grep -q '^GRUB_TERMINAL_OUTPUT="gfxterm"' /etc/default/grub; then
    echo 'GRUB_TERMINAL_OUTPUT="gfxterm"' | sudo tee -a /etc/default/grub > /dev/null
fi

sudo grub2-mkconfig -o "${GRUB_CFG}"
sudo rm -rf "${TMP_DIR}"
