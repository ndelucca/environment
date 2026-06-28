#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=../vars.sh
source "$(dirname "${BASH_SOURCE[0]}")/../vars.sh"   # provee LOCALE, TIMEZONE, KEYMAP, KEYMAP_X11

echo "Fedora $0"
echo "Configuring locale (${LOCALE}) keymap (${KEYMAP}) and timezone (${TIMEZONE})..."

sudo localectl set-locale "LANG=${LOCALE}"
sudo timedatectl set-timezone "${TIMEZONE}"
sudo localectl set-keymap "${KEYMAP}"
sudo localectl set-x11-keymap "${KEYMAP_X11}"

echo "Localization - datetime - keyboard configured successfully!"
localectl status | grep "System Locale" || true
localectl status | grep -E 'Keymap|Layout' || true
timedatectl | grep "Time zone" || true

# El layout de teclado de la SESIÓN sway se genera como override en ~/.config
# (sway/config.d/10-keyboard.conf, desde KEYMAP_X11 en vars.sh) por 04-stow.sh — acá
# solo seteamos el default del sistema con localectl, sin tocar /usr/share.

