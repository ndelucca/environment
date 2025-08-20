#!/usr/bin/env bash

# Credits to unsung hero @pablos123

set -e
set -u
set -o pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires superuser permissions for installation."
  exit 1
fi

function install_nvm() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    [[ -s "${HOME}/.nvm/nvm.sh" ]] || exit 1

    source "${HOME}/.nvm/nvm.sh"
    nvm install --lts
}

install_nvm
