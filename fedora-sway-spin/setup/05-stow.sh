#!/usr/bin/env bash

set -euo pipefail

STOW_DIR="${HOME}/environment/fedora-sway-spin/dotfiles"
BASHRC=.bashrc.d
CONFIG=.config
LOCAL=.local

mkdir -p "${HOME}/${BASHRC}"
mkdir -p "${HOME}/${CONFIG}"
mkdir -p "${HOME}/${LOCAL}"

cd "${STOW_DIR}"
stow -t "${HOME}/${BASHRC}" "${BASHRC}"
stow -t "${HOME}/${CONFIG}" "${CONFIG}"
stow -t "${HOME}/${LOCAL}" "${LOCAL}"
