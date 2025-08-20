#!/usr/bin/bash

set -euo pipefail

check_pre_requisites() {
  echo "Checking prerequisites..."
}

install_dependencies() {
  local dependencies=(
    meson
    libwlroots-dev
    libwayland-dev
    wayland-protocols
    libpcre2-dev
    libjson-c-dev
    libpango1.0-dev
    libcairo2-dev
    libgdk-pixbuf2.0-dev
    scdoc
    git

    libcairo2-dev

    cmake

    vala
    blueprint-compiler
    sassc
    libgtk-4-dev
    libgtk4-layer-shell-dev
    libdbus-1-dev
    libgirepository1.0-dev
    libpulse-dev
    libnotify-dev
    libgee-0.8-dev
    libjson-glib-dev
    libadwaita-1-dev
    gvfs
    libgranite-dev

    imagemagick

    libwayland-client0
    libxkbcommon-dev
    libpam0g-dev

    libgtk-3-dev
    libglib2.0-dev

    wl-clipboard
    fonts-font-awesome
  )

  echo "Installing build dependencies..."
  sudo apt-get update
  sudo apt-get install -y "${dependencies[@]}"
}

build_and_install_sway() {

  readonly SWAY_REPO="https://github.com/swaywm/sway.git"
  readonly SWAY_INSTALL_PREFIX="/opt/sway"
  readonly SWAY_REPOS_DIR="${SWAY_INSTALL_PREFIX}/repos"
  readonly SWAY_SOURCE_DIR="${SWAY_REPOS_DIR}/sway"

  echo "Preparing installation directories..."
  mkdir -p "${SWAY_REPOS_DIR}"

  echo "Removing any previous installations for a clean update..."
  rm -rf "${SWAY_SOURCE_DIR}"

  echo "Cloning repository into '${SWAY_SOURCE_DIR}'..."
  git clone "$SWAY_REPO" "$SWAY_SOURCE_DIR"

  cd "$SWAY_SOURCE_DIR"

  echo "Installing Sway..."
  meson build/
  ninja -C build/
  ninja -C build/ install

  echo "Sway has been installed."
  echo "Running 'sway --version' to verify the installation:"
  sway --version
}

build_and_install_swaybg() {

  readonly SWAYBG_REPO="https://github.com/swaywm/swaybg.git"
  readonly SWAYBG_INSTALL_PREFIX="/opt/swaybg"
  readonly SWAYBG_REPOS_DIR="${SWAYBG_INSTALL_PREFIX}/repos"
  readonly SWAYBG_SOURCE_DIR="${SWAYBG_REPOS_DIR}/swaybg"

  echo "Preparing installation directories..."
  mkdir -p "${SWAYBG_REPOS_DIR}"

  echo "Removing any previous installations for a clean update..."
  rm -rf "${SWAYBG_SOURCE_DIR}"

  echo "Cloning repository into '${SWAYBG_SOURCE_DIR}'..."
  git clone "$SWAYBG_REPO" "$SWAYBG_SOURCE_DIR"

  cd "$SWAYBG_SOURCE_DIR"

  echo "Installing swaybg..."
  meson build/
  ninja -C build/
  ninja -C build/ install

  echo "swaybg has been installed."
}

build_and_install_swaync() {

  readonly SWAYNC_REPO="https://github.com/ErikReider/SwayNotificationCenter.git"
  readonly SWAYNC_INSTALL_PREFIX="/opt/swaync"
  readonly SWAYNC_REPOS_DIR="${SWAYNC_INSTALL_PREFIX}/repos"
  readonly SWAYNC_SOURCE_DIR="${SWAYNC_REPOS_DIR}/swaync"

  echo "Preparing installation directories..."
  mkdir -p "${SWAYNC_REPOS_DIR}"

  echo "Removing any previous installations for a clean update..."
  rm -rf "${SWAYNC_SOURCE_DIR}"

  echo "Cloning repository into '${SWAYNC_SOURCE_DIR}'..."
  git clone "$SWAYNC_REPO" "$SWAYNC_SOURCE_DIR"

  cd "$SWAYNC_SOURCE_DIR"

  echo "Installing sway-notification-center..."
  meson setup build/ --prefix=/usr
  ninja -C build
  meson install -C build
}

build_and_install_swaylock() {

  readonly SWAYLOCK_REPO="https://github.com/swaywm/swaylock.git"
  readonly SWAYLOCK_INSTALL_PREFIX="/opt/swaylock"
  readonly SWAYLOCK_REPOS_DIR="${SWAYLOCK_INSTALL_PREFIX}/repos"
  readonly SWAYLOCK_SOURCE_DIR="${SWAYLOCK_REPOS_DIR}/swaylock"

  echo "Preparing installation directories..."
  mkdir -p "${SWAYLOCK_REPOS_DIR}"

  echo "Removing any previous installations for a clean update..."
  rm -rf "${SWAYLOCK_SOURCE_DIR}"

  echo "Cloning repository into '${SWAYLOCK_SOURCE_DIR}'..."
  git clone "$SWAYLOCK_REPO" "$SWAYLOCK_SOURCE_DIR"

  cd "$SWAYLOCK_SOURCE_DIR"

  echo "Installing swaylock..."
  meson build
  ninja -C build
  ninja -C build install
}

build_and_install_waybar() {
  local dependencies=(
      libgtkmm-3.0-dev
      libjsoncpp-dev
      libsigc++-2.0-dev
      libfmt-dev
      # libdate-dev
      libspdlog-dev
      libgtk-3-dev
      libgirepository1.0-dev
      libpulse-dev
      libnl-3-dev
      libnl-route-3-dev
      libappindicator3-dev
      libdbusmenu-gtk3-dev
      libmpdclient-dev
      libsndio-dev
      libevdev-dev
      libxkbregistry-dev
      libupower-glib-dev
  )
  sudo apt-get install -y "${dependencies[@]}"

  readonly WAYBAR_REPO="https://github.com/Alexays/Waybar.git"
  readonly WAYBAR_INSTALL_PREFIX="/opt/waybar"
  readonly WAYBAR_REPOS_DIR="${WAYBAR_INSTALL_PREFIX}/repos"
  readonly WAYBAR_SOURCE_DIR="${WAYBAR_REPOS_DIR}/waybar"

  echo "Preparing installation directories..."
  mkdir -p "${WAYBAR_REPOS_DIR}"

  echo "Removing any previous installations for a clean update..."
  rm -rf "${WAYBAR_SOURCE_DIR}"

  echo "Cloning repository into '${WAYBAR_SOURCE_DIR}'..."
  git clone "$WAYBAR_REPO" "$WAYBAR_SOURCE_DIR"

  cd "$WAYBAR_SOURCE_DIR"

  echo "Installing Waybar..."
  meson setup build
  ninja -C build
  ninja -C build install

  echo "waybar has been installed."

}

build_and_install_swappy() {

  readonly SWAPPY_REPO="https://github.com/jtheoof/swappy.git"
  readonly SWAPPY_INSTALL_PREFIX="/opt/swappy"
  readonly SWAPPY_REPOS_DIR="${SWAPPY_INSTALL_PREFIX}/repos"
  readonly SWAPPY_SOURCE_DIR="${SWAPPY_REPOS_DIR}/swappy"

  echo "Preparing installation directories..."
  mkdir -p "${SWAPPY_REPOS_DIR}"

  echo "Removing any previous installations for a clean update..."
  rm -rf "${SWAPPY_SOURCE_DIR}"

  echo "Cloning repository into '${SWAPPY_SOURCE_DIR}'..."
  git clone "$SWAPPY_REPO" "$SWAPPY_SOURCE_DIR"

  cd "$SWAPPY_SOURCE_DIR"

  echo "Installing swappy..."
  meson build
  ninja -C build
  ninja -C build install
}

main() {

  check_pre_requisites

  sudo apt install sway swaybg sway-notification-center swaylock i3status wofi wl-clipboard fonts-font-awesome

  # install_dependencies

  # build_and_install_sway
  # build_and_install_swaybg
  # build_and_install_swaync
  # build_and_install_swaylock
  # build_and_install_waybar
  # build_and_install_swappy

}

main "$@"
