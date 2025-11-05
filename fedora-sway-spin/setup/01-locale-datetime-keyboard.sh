#!/usr/bin/env bash

set -euo pipefail

LOCALE="en_US.UTF-8"
TIMEZONE="America/Argentina/Buenos_Aires"
KEYMAP="us-euro" # KEYMAP="latam"
KEYMAP_X11="eu" # KEYMAP="latam"

echo "Fedora $0"
echo "Configuring locale (${LOCALE}) keymap (${KEYMAP}) and timezone (${TIMEZONE})..."

sudo localectl set-locale LANG=${LOCALE}
sudo timedatectl set-timezone "${TIMEZONE}"
sudo localectl set-keymap "${KEYMAP}"
sudo localectl set-x11-keymap "${KEYMAP_X11}"

echo "Localization - datetime - keyboard configured successfully!"
localectl status | grep "System Locale" || true
localectl status | grep -E 'Keymap|Layout' || true
timedatectl | grep "Time zone" || true

echo "Setting up Sway keyboard"

RAW_LAYOUT=$(localectl status | awk '/X11 Layout/ {print $3}')
RAW_VARIANT=$(localectl status | awk '/X11 Variant/ {print $3}')

LAYOUT_LINE="xkb_layout ${RAW_LAYOUT:-us}"
VARIANT_LINE=$([[ -n "$RAW_VARIANT" && "$RAW_VARIANT" != "n/a" ]] && echo "xkb_variant $RAW_VARIANT" || echo "")

sudo tee /usr/share/sway/config.d/10-keyboard.conf > /dev/null <<EOF
# Auto-generated from system settings
input * {
    ${LAYOUT_LINE}
    ${VARIANT_LINE}
}
EOF

