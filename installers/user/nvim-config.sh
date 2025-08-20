#!/usr/bin/env bash

set -euo pipefail

readonly NVIM_CONFIG_REPO="ssh://git@github.com/ndelucca/nvim.git"
readonly NVIM_CONFIG_DIR="${HOME}/.config/nvim"

check_pre_requisites() {
  echo "Checking prerequisites..."
  if ! command -v git &> /dev/null; then
    echo "ERROR: git is not installed. Please install git first." >&2
    exit 1
  fi
}

install_nvim_config() {
  echo "Setting up Neovim configuration in '${NVIM_CONFIG_DIR}'..."
  
  # Create .config directory if it doesn't exist
  mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"
  
  if [ -d "$NVIM_CONFIG_DIR" ]; then
    echo "Neovim config directory exists. Updating with git pull..."
    cd "$NVIM_CONFIG_DIR"
    git pull
  else
    echo "Cloning Neovim configuration from repository..."
    git clone "$NVIM_CONFIG_REPO" "$NVIM_CONFIG_DIR"
  fi
  
  echo "Neovim configuration has been set up successfully."
}

main() {
  check_pre_requisites
  install_nvim_config
}

main "$@"