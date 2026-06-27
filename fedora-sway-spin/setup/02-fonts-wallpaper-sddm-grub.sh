#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=../vars.sh
source "$(dirname "${BASH_SOURCE[0]}")/../vars.sh"   # provides SETUP_DIR

echo "Updating system wallpaper"
sudo cp "${SETUP_DIR}/wallpaper.png" /usr/share/backgrounds/wallpaper.png

echo "SDDM configuration"
echo "Updating sddm wallpaper"
sudo cp /usr/share/backgrounds/default.jxl /usr/share/backgrounds/default.jxl.bak
sudo cp "${SETUP_DIR}/wallpaper.png" /usr/share/backgrounds/default.jxl

echo "Creating sddm configuration file"
sudo tee /etc/sddm.conf.d/ndelucca.conf >/dev/null <<'EOF'
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

if ! sudo test -f "${THEME_FILE}"; then
    sudo git clone --depth=1 "${REPO_URL}" "${TMP_DIR}/repo"
    sudo mkdir -p /boot/grub2/themes
    sudo rm -rf "${THEME_DIR}"
    sudo cp -r "${TMP_DIR}/repo/breeze" "${THEME_DIR}"

    sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
    echo "GRUB_THEME=\"${THEME_FILE}\"" | sudo tee -a /etc/default/grub >/dev/null

    if ! grep -q '^GRUB_TERMINAL_OUTPUT="gfxterm"' /etc/default/grub; then
        echo 'GRUB_TERMINAL_OUTPUT="gfxterm"' | sudo tee -a /etc/default/grub >/dev/null
    fi

    sudo grub2-mkconfig -o "${GRUB_CFG}"
    sudo rm -rf "${TMP_DIR}"
else
    echo "Theme already installed at ${THEME_FILE}"
fi

echo "Configuring rofi"

REPO_URL="https://github.com/newmanls/rofi-themes-collection.git"
TMP_DIR="$(mktemp -d)"
TARGET_DIR="/usr/share/rofi/themes"

if [ ! -f "${TARGET_DIR}/themes-installed" ]; then
    sudo git clone --depth=1 "${REPO_URL}" "${TMP_DIR}/repo"
    sudo mkdir -p "${TARGET_DIR}"
    sudo cp -r ${TMP_DIR}/repo/themes/* ${TARGET_DIR}/
    sudo rm -rf "${TMP_DIR}"
    sudo touch "${TARGET_DIR}/themes-installed"
fi
