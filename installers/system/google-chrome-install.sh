#!/usr/bin/env bash
# Credits to unsung hero @pablos123

set -euo pipefail

echo "Installing Google Chrome..."

# Add Google Chrome repository
curl -fsSL 'https://dl-ssl.google.com/linux/linux_signing_key.pub' | sudo gpg --yes --dearmor -o /usr/share/keyrings/google-chrome.gpg
echo 'deb [signed-by=/usr/share/keyrings/google-chrome.gpg arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

# Install Chrome and dependencies
sudo apt-get update
sudo apt-get install -y google-chrome-stable xdg-utils fonts-noto-color-emoji

# Set as default browser
xdg-settings set default-web-browser 'google-chrome.desktop'

echo "Google Chrome installed successfully"
