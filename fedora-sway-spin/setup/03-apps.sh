#!/usr/bin/env bash

set -euo pipefail

sudo dnf copr enable agriffis/neovim-nightly -y
sudo dnf install -y \
    swaync swappy \
    gawk unzip curl ripgrep htop direnv cowsay fortune-mod \
    tmux mycli \
    chromium firefox neovim python3-neovim \
    ansible

if command -v gh &>/dev/null; then
    echo "GitHub CLI is already installed."
    echo "Version: $(gh --version | head -n1)"
else
    echo "Installing GitHub CLI from official repository..."

    sudo dnf install -y dnf5-plugins
    sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install -y gh --repo gh-cli

    echo "GitHub CLI installed successfully!"
    echo "Version: $(gh --version | head -n1)"
fi

if command -v code &>/dev/null; then
    echo "VSCode is already installed."
    echo "Version: $(code --version | head -n1)"
    INSTALL_VSCODE=false
else
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
