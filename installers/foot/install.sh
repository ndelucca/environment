#!/usr/bin/env bash

set -e
set -u
set -o pipefail

FOOT_REPO="https://codeberg.org/dnkl/foot.git"
FOOT_SOURCE_DIR="/opt/foot"
INSTALL_PREFIX="/usr/local"
BUILD_DIR="build"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

cleanup() {
  echo "Checking for previous installation..."
  if command_exists "foot"; then
    echo "Found existing 'foot' binary at $(which foot). Removing it..."
    rm -f "$(which foot)"
  fi

  if [ -d "$FOOT_SOURCE_DIR" ]; then
    echo "Found old build directory at $FOOT_SOURCE_DIR. Removing it..."
    rm -rf "$FOOT_SOURCE_DIR"
  fi
}

echo "Installing Foot"

if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires superuser permissions for installation."
  exit 1
fi

cleanup

# Install build dependencies using apt-get.
echo "Installing build dependencies via apt-get..."
apt-get update
apt-get install -y meson ninja-build scdoc libwayland-dev wayland-protocols libxkbcommon-dev git

# Clone the Foot repository into the specified temporary directory.
echo "Cloning Foot repository into $FOOT_SOURCE_DIR..."
git clone "$FOOT_REPO" "$FOOT_SOURCE_DIR"

# Build and install Foot.
echo "Building and installing Foot from source..."
(
  # Change to the source directory, then build and install.
  # Using for these commands because the directory is owned by root.
  cd "$FOOT_SOURCE_DIR"
  meson setup "$BUILD_DIR"
  ninja -C "$BUILD_DIR"
  ninja -C "$BUILD_DIR" install
)

echo "Updating dynamic linker run-time bindings."
ldconfig

echo "Installation complete! Foot is installed to $INSTALL_PREFIX/bin/foot."

exit 0
