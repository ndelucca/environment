#!/usr/bin/env bash

# Credits to unsung hero @pablos123

set -e
set -u
set -o pipefail

function install_nvm() {
    echo "Installing Node Version Manager (NVM)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    
    # Check if nvm was installed correctly
    if [[ ! -s "${HOME}/.nvm/nvm.sh" ]]; then
        echo "ERROR: NVM installation failed"
        exit 1
    fi

    echo "Loading NVM and installing latest LTS Node.js..."
    source "${HOME}/.nvm/nvm.sh"
    nvm install --lts
    
    echo "NVM and Node.js LTS installed successfully"
}

install_nvm
