#!/usr/bin/env bash
set -euo pipefail

echo "Configuring English US locale and Buenos Aires timezone..."
echo "Setting up English US locale..."
sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

sudo tee /etc/default/locale > /dev/null << EOF
LANG=en_US.UTF-8
LANGUAGE=en_US:en
LC_ALL=en_US.UTF-8
EOF

echo "Setting timezone to Buenos Aires..."
sudo timedatectl set-timezone America/Argentina/Buenos_Aires 2>/dev/null || {
    sudo ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
    echo "America/Argentina/Buenos_Aires" | sudo tee /etc/timezone
}

echo "America/Argentina/Buenos_Aires" | sudo tee /etc/timezone
sudo dpkg-reconfigure -f noninteractive tzdata

echo "Localization configured successfully!"
echo "Current locale: $(locale | grep LANG=)"
echo "Current timezone: $(cat /etc/timezone)"
echo "Please reboot for all changes to take effect."
