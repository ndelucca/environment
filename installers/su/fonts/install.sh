#!/usr/bin/env bash

# Credits to unsung hero @pablos123

set -e
set -u
set -o pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires superuser permissions for installation."
  exit 1
fi

function install_fonts() {
    local font fonts fonts_path

    fonts=(
        JetBrainsMono
    )

    fonts_path=/usr/share/fonts

    mkdir -p "${fonts_path}"
    for font in "${fonts[@]}"; do
        rm -rf "${fonts_path}/${font}Nerd"
        mkdir -p "${fonts_path}/${font}Nerd"
        wget -O "${fonts_path}/${font}Nerd.tar.xz" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.tar.xz"
        tar -xf "${fonts_path}/${font}Nerd.tar.xz" -C "${fonts_path}/${font}Nerd"
        rm -f "${fonts_path}/${font}Nerd.tar.xz"
    done

    fc-cache -f -v
}

install_fonts
