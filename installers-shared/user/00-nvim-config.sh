#!/usr/bin/env bash
set -euo pipefail

echo "Setting up Neovim configuration..."

# Check git availability
if ! command -v git &> /dev/null; then
    echo "ERROR: git is not installed. Please install git first." >&2
    exit 1
fi

config_dir="${HOME}/.config/nvim"
repo="ssh://git@github.com/ndelucca/nvim.git"

# Setup or update config
mkdir -p "$(dirname "$config_dir")"

if [ -d "$config_dir" ]; then
    echo "Updating existing configuration..."
    cd "$config_dir"
    git pull
else
    echo "Cloning Neovim configuration..."
    git clone "$repo" "$config_dir"
fi

echo "Neovim configuration setup complete"