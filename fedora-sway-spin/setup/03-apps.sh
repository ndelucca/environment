#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=../vars.sh
source "$(dirname "${BASH_SOURCE[0]}")/../vars.sh"   # provides SETUP_DIR
PKG_FILE="${SETUP_DIR}/packages.txt"

# Some packages.txt entries aren't in Fedora's repos and ship from a COPR. Enable
# them (idempotent) before the bulk install so the packages resolve:
#   jhuang6451/nerd-fonts  -> jetbrains-mono-nf (JetBrainsMono Nerd Font)
#   erikreider/swayosd     -> swayosd (volume/brightness/caps-lock OSD)
COPRS=(
    "jhuang6451/nerd-fonts"
    "erikreider/swayosd"
)
for copr in "${COPRS[@]}"; do
    if ! sudo dnf copr list 2>/dev/null | grep -q "${copr}"; then
        echo "Enabling COPR ${copr}..."
        sudo dnf install -y dnf5-plugins
        sudo dnf copr enable -y "${copr}"
    fi
done

echo "Installing dnf packages from ${PKG_FILE}..."
mapfile -t PACKAGES < <(grep -vE '^\s*(#|$)' "${PKG_FILE}")
sudo dnf install -y "${PACKAGES[@]}"

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

# Zed via its official script. Not in dnf — the 'zed' dnf package is the unrelated
# ZFS event daemon.
if command -v zed &>/dev/null; then
    echo "Zed is already installed."
else
    echo "Installing Zed from zed.dev..."
    curl -f https://zed.dev/install.sh | sh
    echo "Zed installed successfully!"
fi
