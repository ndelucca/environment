#!/usr/bin/env bash

# Credits to unsung hero @pablos123

set -e
set -u
set -o pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires superuser permissions for installation."
  exit 1
fi

dependencies=(
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
)

echo -e "Installing dependencies..."
apt install -y "${dependencies[@]}"

echo "Making necessary directories..."
mkdir -p "/opt/nvim" "/opt/nvim/repos/"

echo "Deleting repository directory..."
rm -rf /opt/nvim/repos/neovim/

echo -e "Cloning repo..."
git clone https://github.com/neovim/neovim /opt/nvim/repos/neovim/

cd /opt/nvim/repos/neovim/ || exit 1

echo -e "Making neovim..."
make CMAKE_BUILD_TYPE=RelWithDebInfo

echo -e "Installing neovim..."
make install

echo -e "All done! Neovim installed..."
nvim --version
