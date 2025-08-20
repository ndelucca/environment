#!/usr/bin/bash

set -euo pipefail

readonly SYSTEM_USER="ndelucca"

check_pre_requisites() {
  echo "Checking prerequisites..."
  if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run with superuser permissions (as root)." >&2
    exit 1
  fi
}

install_wayland() {
  local dependencies=(
    wl-clipboard
    wayland-utils
    dbus-user-session
    seatd
    systemd-container
    xdg-user-dirs
    mesa-vulkan-drivers
  )

  echo "Installing wayland..."
  apt-get update
  apt-get install -y "${dependencies[@]}"
}

main() {
  check_pre_requisites
  install_wayland
  echo "Enabling seatd..."
  systemctl start seatd
  systemctl enable seatd
  gpasswd -a "${SYSTEM_USER}" render
}

main "$@"

