#!/usr/bin/env bash

# Credits to unsung hero @pablos123

set -euo pipefail

readonly NVIM_REPO="https://github.com/neovim/neovim.git"
readonly INSTALL_PREFIX="/opt/nvim"
readonly REPOS_DIR="${INSTALL_PREFIX}/repos"
readonly NVIM_SOURCE_DIR="${REPOS_DIR}/neovim"


check_pre_requisites() {
  echo "Checking prerequisites..."
  if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run with superuser permissions (as root)." >&2
    exit 1
  fi
}

install_dependencies() {
  local dependencies=(
    ninja-build
    gettext
    libtool
    libtool-bin
    autoconf
    automake
    cmake
    g++
    pkg-config
    unzip
    curl
    doxygen
    git
  )
  echo "Installing build dependencies..."
  apt-get update
  apt-get install -y "${dependencies[@]}"
}

build_and_install_neovim() {
  echo "Preparing installation directories..."
  mkdir -p "${REPOS_DIR}"

  echo "Removing any previous installations for a clean update..."
  rm -rf "${NVIM_SOURCE_DIR}"

  echo "Cloning the Neovim repository into '${NVIM_SOURCE_DIR}'..."
  git clone "$NVIM_REPO" "$NVIM_SOURCE_DIR"

  cd "$NVIM_SOURCE_DIR"

  echo "Building Neovim..."
  make CMAKE_BUILD_TYPE=RelWithDebInfo

  echo "Installing Neovim to '${INSTALL_PREFIX}'..."
  make install
}

main() {
  check_pre_requisites
  install_dependencies
  build_and_install_neovim

  echo "Neovim has been installed to '${INSTALL_PREFIX}'."
  echo "Running 'nvim --version' to verify the installation:"
  nvim --version
}

main "$@"
