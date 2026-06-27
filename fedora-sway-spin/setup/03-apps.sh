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

# Neovide: GUI client for our Neovim. Not in dnf/COPR. The Flathub build runs nvim in
# a sandbox (it wouldn't use our host nvim / LSPs / Go / Node), so we install the
# official release binary into ~/.local/bin (same approach as Zed). It just drives our
# existing nvim config (the submodule), so it's the GUI of our nvim, not a 3rd editor.
#
# The binary is installed as `neovide-bin`; the launcher on PATH is the stowed wrapper
# dotfiles/.local/bin/neovide, which falls back to software GL on old GPUs (Neovide
# needs OpenGL >= 3.2). See that wrapper for details.
if command -v neovide-bin &>/dev/null; then
    echo "Neovide is already installed."
else
    echo "Installing Neovide from GitHub release..."
    NEOVIDE_TMP="$(mktemp -d)"
    # Release asset is a plain .tar (not .tar.gz) containing the neovide binary.
    curl -fL https://github.com/neovide/neovide/releases/latest/download/neovide-linux-x86_64.tar \
        -o "${NEOVIDE_TMP}/neovide.tar"
    tar -xf "${NEOVIDE_TMP}/neovide.tar" -C "${NEOVIDE_TMP}"
    NEOVIDE_BIN="$(find "${NEOVIDE_TMP}" -type f -name neovide | head -n1)"
    mkdir -p "${HOME}/.local/bin"
    install -m755 "${NEOVIDE_BIN}" "${HOME}/.local/bin/neovide-bin"

    # Desktop entry + icon so it shows up in rofi. Exec=neovide -> the stowed wrapper.
    # Under Wayland the app_id is "neovide" (matched by sway's `assign ... workspace 3`).
    mkdir -p "${HOME}/.local/share/icons/hicolor/scalable/apps"
    curl -fsL https://raw.githubusercontent.com/neovide/neovide/main/assets/neovide.svg \
        -o "${HOME}/.local/share/icons/hicolor/scalable/apps/neovide.svg" || true
    mkdir -p "${HOME}/.local/share/applications"
    tee "${HOME}/.local/share/applications/neovide.desktop" >/dev/null <<'EOF'
[Desktop Entry]
Name=Neovide
GenericName=Text Editor
Comment=No Nonsense Neovim GUI
Exec=neovide %F
Icon=neovide
Type=Application
Categories=Utility;TextEditor;Development;
Terminal=false
StartupWMClass=neovide
MimeType=text/plain;
EOF

    rm -rf "${NEOVIDE_TMP}"
    echo "Neovide installed to ~/.local/bin/neovide"
fi

# Default file handlers. ~/.config/mimeapps.list is a real file that the system and
# apps rewrite, so it is NOT stowed (that would clash with stow's --no-folding and
# clobber the browser/nvim defaults already there). We set only our handlers with
# xdg-mime, which merges into that file idempotently and leaves the rest intact.
if command -v xdg-mime &>/dev/null; then
    echo "Setting default file handlers (images=Loupe, pdf=Papers, video=mpv)..."
    xdg-mime default org.gnome.Loupe.desktop \
        image/png image/jpeg image/gif image/webp image/bmp image/tiff image/svg+xml
    xdg-mime default org.gnome.Papers.desktop application/pdf
    xdg-mime default mpv.desktop \
        video/mp4 video/x-matroska video/webm video/quicktime video/x-msvideo
    xdg-mime default thunar.desktop inode/directory
fi
