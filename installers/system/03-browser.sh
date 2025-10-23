#!/usr/bin/env bash
set -euo pipefail
# Credits to unsung hero @pablos123


echo "Installing Google Chrome..."

curl -fsSL 'https://dl-ssl.google.com/linux/linux_signing_key.pub' | sudo gpg --yes --dearmor -o /usr/share/keyrings/google-chrome.gpg
echo 'deb [signed-by=/usr/share/keyrings/google-chrome.gpg arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

sudo apt-get update
sudo apt-get install -y google-chrome-stable xdg-utils fonts-noto-color-emoji

echo "Google Chrome installed successfully"

echo "Installing Firefox..."

# Create directory for APT repository keyrings if it doesn't exist
sudo install -d -m 0755 /etc/apt/keyrings

# Import Mozilla APT repository signing key
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

# Add Mozilla APT repository using DEB822 format (for Debian 13/Trixie)
cat <<EOF | sudo tee /etc/apt/sources.list.d/mozilla.sources
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF

# Configure APT to prioritize packages from Mozilla repository
echo 'Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000' | sudo tee /etc/apt/preferences.d/mozilla > /dev/null

# Update package list and install Firefox
sudo apt-get update
sudo apt-get install -y firefox

# Set Firefox as default browser
xdg-settings set default-web-browser firefox.desktop

echo "Firefox installed successfully and set as default browser"

