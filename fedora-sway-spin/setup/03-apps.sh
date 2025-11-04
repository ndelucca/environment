#!/usr/bin/env bash

set -euo pipefail

sudo dnf copr enable agriffis/neovim-nightly
sudo dnf install -y \
    swaync swappy \
    gawk unzip curl ripgrep htop direnv cowsay fortune-mod \
    tmux mycli \
    chromium \
    neovim python3-neovim

echo "Setting up Neovim configuration..."
CONFIG_DIR="${HOME}/.config/nvim"
REPO="ssh://git@github.com/ndelucca/nvim.git"

mkdir -p "$(dirname "$CONFIG_DIR")"

if [ -d "$CONFIG_DIR" ]; then
    cd "$CONFIG_DIR"
    git pull
else
    git clone "$REPO" "$CONFIG_DIR"
fi

