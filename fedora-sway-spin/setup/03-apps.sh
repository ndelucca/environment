#!/usr/bin/env bash

set -euo pipefail

sudo dnf copr enable agriffis/neovim-nightly
sudo dnf install -y \
    swaync swappy \
    gawk unzip curl ripgrep htop direnv cowsay fortune-mod \
    tmux mycli \
    chromium \
    neovim python3-neovim

