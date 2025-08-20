#!/usr/bin/env bash
set -euo pipefail

echo "Installing Foot terminal emulator from source..."

# Install dependencies
echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y \
    libfontconfig1-dev libstdc++-14-dev meson cmake pkg-config \
    libpixman-1-dev ninja-build scdoc libwayland-dev wayland-protocols \
    libxkbcommon-dev git

# Create temporary directory
tmp_dir=$(mktemp -d)
cleanup() { rm -rf "$tmp_dir"; }
trap cleanup EXIT

# Clone and build
echo "Cloning Foot repository..."
git clone "https://codeberg.org/dnkl/foot.git" "$tmp_dir/foot"
cd "$tmp_dir/foot"

echo "Building Foot..."
meson setup build --prefix="/usr/local"
ninja -C build

echo "Installing Foot..."
sudo ninja -C build install
sudo ldconfig

echo "Foot terminal installed successfully to /usr/local/bin/foot"