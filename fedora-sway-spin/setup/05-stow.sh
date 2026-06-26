#!/usr/bin/env bash

set -euo pipefail

STOW_DIR="${HOME}/nd.environment/fedora-sway-spin/dotfiles"

# --no-folding symlinks files individually (real dirs) instead of folding whole
# directories — so files apps write into ~/.config stay out of the repo.
for pkg in .bashrc.d .config .local; do
    mkdir -p "${HOME}/${pkg}"
    stow --no-folding -d "${STOW_DIR}" -t "${HOME}/${pkg}" "${pkg}"
done
