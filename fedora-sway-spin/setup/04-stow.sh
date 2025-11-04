#!/usr/bin/env bash

set -euo pipefail

STOW_DIR="${HOME}/environment/fedora-sway-spin/dotfiles"
CONFIG_DIR="${HOME}/.config"

cd "${STOW_DIR}"
stow -t ${CONFIG_DIR} .config
