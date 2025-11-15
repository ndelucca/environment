#!/usr/bin/env bash

set -euo pipefail

sudo dnf copr enable agriffis/neovim-nightly -y
sudo dnf install -y \
    swaync swappy \
    gawk unzip curl ripgrep htop direnv cowsay fortune-mod \
    tmux mycli \
    chromium firefox neovim python3-neovim

if command -v code &>/dev/null; then
    echo "VSCode is already installed."
    echo "Version: $(code --version | head -n1)"
    read -p "Do you want to skip VSCode installation? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "Skipping VSCode installation..."
    else
        INSTALL_VSCODE=true
    fi
else
    INSTALL_VSCODE=true
fi

if [ "$INSTALL_VSCODE" = true ]; then
    echo "Installing VSCode from Microsoft repository..."

    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
    sudo dnf check-update || true
    sudo dnf install -y code

    echo "VSCode installed successfully!"
    echo "Version: $(code --version | head -n1)"

    code --install-extension asvetliakov.vscode-neovim
    code --install-extension dracula-theme.theme-dracula
    code --install-extension ms-python.python
    code --install-extension charliermarsh.ruff
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension esbenp.prettier-vscode
    code --install-extension ecmel.vscode-html-css
    code --install-extension redhat.ansible
    code --install-extension redhat.vscode-yaml
    code --install-extension redhat.vscode-xml
    code --install-extension ms-dotnettools.csharp
    code --install-extension csharpier.csharpier-vscode
    code --install-extension JohnnyMorganz.stylua

fi
