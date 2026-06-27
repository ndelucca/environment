#!/usr/bin/env bash
# Power menu en rofi, a juego con el sistema (tema powermenu.rasi).
# Invocado por sway: $mod+BackSpace. Glifos Nerd Font (Font Awesome).

set -euo pipefail

options="\
  Lock
  Logout
  Suspend
  Reboot
  Shutdown"

chosen="$(printf '%s' "$options" | rofi -dmenu -i \
    -p "Power" \
    -theme "${HOME}/.config/rofi/powermenu.rasi")"

case "$chosen" in
    *Lock)     loginctl lock-session ;;
    *Logout)   swaymsg exit ;;
    *Suspend)  systemctl suspend ;;
    *Reboot)   systemctl reboot ;;
    *Shutdown) systemctl poweroff ;;
    *)         exit 0 ;;
esac
