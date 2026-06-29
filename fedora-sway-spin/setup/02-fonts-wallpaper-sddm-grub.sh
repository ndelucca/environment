#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=../vars.sh
source "$(dirname "${BASH_SOURCE[0]}")/../vars.sh"   # provee SETUP_DIR

echo "Actualizando wallpaper del sistema"
sudo cp "${SETUP_DIR}/wallpaper.png" /usr/share/backgrounds/wallpaper.png
sudo cp "${SETUP_DIR}/wallpaper-swaylock.png" /usr/share/backgrounds/wallpaper-swaylock.png

echo "Configuración de SDDM"
echo "Actualizando wallpaper de sddm"
# Backup del default original SOLO la primera vez: en re-corridas default.jxl ya es
# nuestro wallpaper, así que sin este guard el .bak terminaría pisando el original.
sudo test -f /usr/share/backgrounds/default.jxl.bak \
    || sudo cp /usr/share/backgrounds/default.jxl /usr/share/backgrounds/default.jxl.bak
# Copiamos un PNG sobre el nombre default.jxl (el que referencia el tema de SDDM del
# Spin). Funciona porque el loader Qt de SDDM detecta el formato por contenido, no por
# la extensión: el .jxl es solo el nombre del archivo, el contenido sigue siendo PNG.
sudo cp "${SETUP_DIR}/wallpaper.png" /usr/share/backgrounds/default.jxl

echo "Creando archivo de configuración de sddm"
sudo tee /etc/sddm.conf.d/ndelucca.conf >/dev/null <<'EOF'
[Autologin]
# User=ndelucca
# Session=sway
[General]
EnableHiDPI=true
[Theme]
EnableAvatars=false
EOF

echo "Configurando GRUB2"

if [ -d /sys/firmware/efi ]; then
    GRUB_CFG="/boot/efi/EFI/fedora/grub.cfg"
else
    GRUB_CFG="/boot/grub2/grub.cfg"
fi
THEME_DIR="/boot/grub2/themes/breeze"
THEME_FILE="${THEME_DIR}/theme.txt"
REPO_URL="https://github.com/gustawho/grub2-theme-breeze.git"

if ! sudo test -f "${THEME_FILE}"; then
    # El tmpdir se crea solo en el camino de instalación, así no queda basura en
    # /tmp cuando el tema ya está y este paso es no-op.
    TMP_DIR="$(mktemp -d)"
    # git clone corre con sudo, así que el contenido queda root-owned: el cleanup también.
    trap 'sudo rm -rf "${TMP_DIR:-}"' EXIT
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
else
    echo "Tema ya instalado en ${THEME_FILE}"
fi

# Rofi se configura por completo vía dotfiles (~/.config/rofi/, tema nd-dark
# autocontenido). No hace falta clonar colecciones de temas externas.
