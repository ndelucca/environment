#!/usr/bin/env bash
set -euo pipefail

echo "Installing Foot terminal emulator..."

sudo apt-get update
sudo apt-get install -y foot

echo "Foot terminal installed successfully"