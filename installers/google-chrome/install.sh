#!/usr/bin/env bash

# Credits to unsung hero @pablos123

set -e
set -u
set -o pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "This script requires superuser permissions for installation."
  exit 1
fi

function install_chrome() {
    curl -fsSL 'https://dl-ssl.google.com/linux/linux_signing_key.pub' | gpg --yes --dearmor -o /usr/share/keyrings/google-chrome.gpg
    (echo 'deb [signed-by=/usr/share/keyrings/google-chrome.gpg arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list) > /dev/null
    apt-get update
    apt-get install --yes google-chrome-stable xdg-utils

    xdg-settings set default-web-browser 'google-chrome.desktop'

    # Fix emojis not rendering
    apt-get install --yes fonts-noto-color-emoji
}

install_chrome
