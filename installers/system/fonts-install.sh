#!/usr/bin/env bash

# Credits to unsung hero @pablos123

set -e
set -u
set -o pipefail

function install_fonts() {
    local font fonts fonts_path

    fonts=(
        JetBrainsMono
    )

    fonts_path=/usr/share/fonts

    sudo mkdir -p "${fonts_path}"
    for font in "${fonts[@]}"; do
        sudo rm -rf "${fonts_path}/${font}Nerd"
        sudo mkdir -p "${fonts_path}/${font}Nerd"
        wget -O "/tmp/${font}Nerd.tar.xz" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.tar.xz"
        sudo tar -xf "/tmp/${font}Nerd.tar.xz" -C "${fonts_path}/${font}Nerd"
        rm -f "/tmp/${font}Nerd.tar.xz"
    done

    sudo fc-cache -f -v
}

install_fonts
