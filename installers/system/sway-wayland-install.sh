#!/usr/bin/bash

set -euo pipefail

readonly SYSTEM_USER="ndelucca"

check_pre_requisites() {
  echo "Checking prerequisites..."
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
  sudo apt-get update
  sudo apt-get install -y "${dependencies[@]}"
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

