#!/usr/bin/env bash
# Settings menu en rofi, a juego con el sistema (tema settings.rasi).
# Invocado por sway: $mod+equal. Glifos Nerd Font (Font Awesome).
set -euo pipefail

options="\
  Audio
  Bluetooth
  Network
  Notifications"

chosen="$(printf '%s' "$options" | rofi -dmenu -i \
    -p "Settings" \
    -theme "${HOME}/.config/rofi/settings.rasi")"

case "$chosen" in
    *Audio)         exec pavucontrol ;;
    *Bluetooth)     exec blueman-manager ;;
    *Network)       exec nm-connection-editor ;;
    *Notifications) exec swaync-client -t -sw ;;
    *)              exit 0 ;;
esac
