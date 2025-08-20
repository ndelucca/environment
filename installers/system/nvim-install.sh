#!/usr/bin/env bash
# Credits to unsung hero @pablos123

set -euo pipefail

echo "Installing Neovim from source..."

# Install build dependencies
echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y \
    ninja-build gettext libtool libtool-bin autoconf automake cmake \
    g++ pkg-config unzip curl doxygen git

# Create installation directory
install_dir="/opt/nvim"
sudo mkdir -p "$install_dir/repos"

# Create temporary directory
tmp_dir=$(mktemp -d)
cleanup() { rm -rf "$tmp_dir"; }
trap cleanup EXIT

# Clone and build
echo "Cloning Neovim repository..."
git clone "https://github.com/neovim/neovim.git" "$tmp_dir/neovim"
cd "$tmp_dir/neovim"

echo "Building Neovim..."
make CMAKE_BUILD_TYPE=RelWithDebInfo

echo "Installing Neovim..."
sudo make install

echo "Neovim installed successfully"
echo "Version: $(nvim --version | head -1)"