#!/usr/bin/env bash

set -euo pipefail

readonly FOOT_REPO="https://codeberg.org/dnkl/foot.git"
readonly INSTALL_PREFIX="/usr/local"
readonly BUILD_DIR="build"

tmp_dir=$(mktemp -d /tmp/foot-install-XXXXXXXX)
readonly SCRIPT_TMP_DIR="$tmp_dir"

cleanup() {
  echo "Cleaning up temporary files..."
  rm -rf "$SCRIPT_TMP_DIR"
}

trap cleanup EXIT

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

check_pre_requisites() {
  echo "Checking prerequisites..."
  if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run with superuser permissions (as root)." >&2
    exit 1
  fi
}

remove_previous_installation() {
  echo "Checking for and removing previous Foot installations..."
  if command_exists "foot"; then
    local foot_path
    foot_path=$(command -v foot)
    echo "Found existing 'foot' binary at '$foot_path'. Removing it..."
    rm -f "$foot_path"
  fi

  if [ -d "$INSTALL_PREFIX/foot" ]; then
    echo "Found old build directory at '$INSTALL_PREFIX/foot'. Removing it..."
    rm -rf "$INSTALL_PREFIX/foot"
  fi
}

install_foot() {
  echo "Installing build dependencies..."
  apt-get update
  apt-get install -y meson ninja-build scdoc libwayland-dev wayland-protocols libxkbcommon-dev git

  echo "Cloning the foot repository into '$SCRIPT_TMP_DIR/foot'..."
  git clone "$FOOT_REPO" "$SCRIPT_TMP_DIR/foot"

  echo "Building and installing foot from source..."
  cd "$SCRIPT_TMP_DIR/foot"
  meson setup "$BUILD_DIR" --prefix="$INSTALL_PREFIX"
  ninja -C "$BUILD_DIR"
  ninja -C "$BUILD_DIR" install
}

main() {
  check_pre_requisites
  remove_previous_installation

  echo "Starting foot installation/update..."
  install_foot

  echo "Updating the dynamic linker run-time bindings..."
  ldconfig

  echo "foot has been installed to '$INSTALL_PREFIX/bin/foot'."
}

main "$@"
