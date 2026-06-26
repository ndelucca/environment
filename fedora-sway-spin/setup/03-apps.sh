#!/usr/bin/env bash

set -euo pipefail

SETUP_DIR="${HOME}/nd.environment/fedora-sway-spin/setup"
PKG_FILE="${SETUP_DIR}/packages.txt"

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
