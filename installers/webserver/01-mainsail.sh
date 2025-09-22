#!/usr/bin/bash

set -e

MAINSAIL_DIR="/opt/mainsail"

echo "Installing dependencies"
sudo apt install -y python3-virtualenv python3-dev libffi-dev build-essential libncurses-dev avrdude gcc-avr binutils-avr avr-libc stm32flash dfu-util libnewlib-arm-none-eabi gcc-arm-none-eabi binutils-arm-none-eabi libusb-1.0-0 libusb-1.0-0-dev libopenjp2-7 python3-libgpiod curl libcurl4-openssl-dev libssl-dev liblmdb-dev libsodium-dev zlib1g-dev libjpeg-dev packagekit wireless-tools

echo "Creating mainsail system user"
if ! id mainsail >/dev/null 2>&1; then
    sudo useradd --system --create-home --home-dir "$MAINSAIL_DIR" --shell /bin/bash --groups dialout mainsail
    echo "Created mainsail user"
else
    echo "mainsail user already exists"
fi

# Create main directory if it doesn't exist
sudo mkdir -p "$MAINSAIL_DIR"
cd "$MAINSAIL_DIR"

echo "Installing klipper"
if [ ! -d "klipper" ]; then
    sudo -u mainsail git clone https://github.com/Klipper3d/klipper
else
    echo "Klipper repository already exists, updating..."
    cd klipper && sudo -u mainsail git pull && cd ..
fi

# Create virtual environment only if it doesn't exist
if [ ! -d "$MAINSAIL_DIR/klippy-env" ]; then
    sudo -u mainsail virtualenv -p python3 "$MAINSAIL_DIR/klippy-env"
fi

# Always update pip requirements (idempotent)
sudo -u mainsail $MAINSAIL_DIR/klippy-env/bin/pip install -r $MAINSAIL_DIR/klipper/scripts/klippy-requirements.txt

# Create directory structure (mkdir -p is idempotent)
sudo -u mainsail mkdir -p "$MAINSAIL_DIR/printer_data"/{config,logs,gcodes,systemd,comms}

echo "Cloning klipper configuration repository"
if [ ! -d "klipper-conf" ]; then
    sudo -u mainsail git clone https://github.com/ndelucca/klipper-conf.git "$MAINSAIL_DIR/klipper-conf"
else
    echo "Klipper configuration repository already exists, updating..."
    cd klipper-conf && sudo -u mainsail git pull && cd ..
fi

echo "Copying printer.cfg from repository"
sudo -u mainsail ln -f -s "$MAINSAIL_DIR/klipper-conf/versions/v1/printer.cfg" "$MAINSAIL_DIR/printer_data/config/printer.cfg"
sudo -u mainsail ln -f -s "$MAINSAIL_DIR/klipper-conf/versions/v1/macros.cfg" "$MAINSAIL_DIR/printer_data/config/macros.cfg"

echo "Creating klipper environment file"
sudo -u mainsail tee "$MAINSAIL_DIR/printer_data/systemd/klipper.env" > /dev/null <<EOF
KLIPPER_ARGS='$MAINSAIL_DIR/klipper/klippy/klippy.py $MAINSAIL_DIR/printer_data/config/printer.cfg -l $MAINSAIL_DIR/printer_data/logs/klippy.log -I $MAINSAIL_DIR/printer_data/comms/klippy.serial -a $MAINSAIL_DIR/printer_data/comms/klippy.sock'
EOF

echo "Installing moonraker"
if [ ! -d "moonraker" ]; then
    sudo -u mainsail git clone https://github.com/Arksine/moonraker.git
else
    echo "Moonraker repository already exists, updating..."
    cd moonraker && sudo -u mainsail git pull && cd ..
fi

# Create virtual environment only if it doesn't exist
if [ ! -d "$MAINSAIL_DIR/moonraker-env" ]; then
    sudo -u mainsail virtualenv -p python3 "$MAINSAIL_DIR/moonraker-env"
fi

# Always update pip requirements (idempotent)
sudo -u mainsail $MAINSAIL_DIR/moonraker-env/bin/pip install -r $MAINSAIL_DIR/moonraker/scripts/moonraker-requirements.txt

echo "Creating moonraker environment file"
sudo -u mainsail tee "$MAINSAIL_DIR/printer_data/systemd/moonraker.env" > /dev/null <<EOF
MOONRAKER_ARGS='$MAINSAIL_DIR/moonraker/moonraker/moonraker.py -d $MAINSAIL_DIR/printer_data'
EOF

echo "Creating moonraker configuration"
sudo -u mainsail tee "$MAINSAIL_DIR/printer_data/config/moonraker.conf" > /dev/null <<EOF
[server]
host: 0.0.0.0
port: 7125
klippy_uds_address: $MAINSAIL_DIR/printer_data/comms/klippy.sock

[authorization]
trusted_clients:
    10.0.0.0/8
    127.0.0.0/8
    169.254.0.0/16
    172.16.0.0/12
    192.168.0.0/16
    FE80::/10
    ::1/128

[file_manager]
enable_object_processing: False

[data_store]
temperature_store_size: 600
gcode_store_size: 1000

[machine]
provider: systemd_dbus
EOF

echo "Enabling services"
sudo systemctl daemon-reload
if ! sudo systemctl is-enabled klipper.service > /dev/null 2>&1; then
    sudo systemctl enable klipper.service
    echo "Klipper service enabled"
else
    echo "Klipper service already enabled"
fi

if ! sudo systemctl is-enabled moonraker.service > /dev/null 2>&1; then
    sudo systemctl enable moonraker.service
    echo "Moonraker service enabled"
else
    echo "Moonraker service already enabled"
fi

echo "Setting PolicyKit rules for moonraker"
$MAINSAIL_DIR/moonraker/scripts/set-policykit-rules.sh || echo "PolicyKit rules installed (service restart failed - expected)"

echo "Downloading mainsail static files"
sudo -u mainsail mkdir -p "$MAINSAIL_DIR/mainsail"
cd "$MAINSAIL_DIR"

# Only download if mainsail directory is empty or doesn't exist
if [ ! -f "mainsail/index.html" ]; then
    echo "Downloading Mainsail web interface..."
    sudo -u mainsail wget -q -O mainsail.zip https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip
    sudo -u mainsail unzip -o mainsail.zip -d mainsail
    sudo -u mainsail rm mainsail.zip
else
    echo "Mainsail web interface already exists, skipping download"
fi

echo "Adding mainsail.local to /etc/hosts"
if ! grep -q "mainsail.local" /etc/hosts; then
    echo "127.0.0.1 mainsail.local" | sudo tee -a /etc/hosts
else
    echo "mainsail.local already exists in /etc/hosts"
fi

echo "Setting permissions for mainsail installation"
# Ensure proper ownership
sudo chown -R mainsail:mainsail "$MAINSAIL_DIR"
# Make web files readable by nginx
sudo chmod -R 755 "$MAINSAIL_DIR/mainsail"
# Make sure mainsail user can access serial devices
sudo usermod -a -G dialout mainsail

echo "Starting services"
sudo systemctl start klipper || echo "Klipper service may already be running"
sudo systemctl start moonraker || echo "Moonraker service may already be running"
