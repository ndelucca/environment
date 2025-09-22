#!/usr/bin/bash

set -e

MAINSAIL_DIR="${HOME}/mainsail"

echo "Installing dependencies"
sudo apt install -y python3-virtualenv python3-dev libffi-dev build-essential libncurses-dev avrdude gcc-avr binutils-avr avr-libc stm32flash dfu-util libnewlib-arm-none-eabi gcc-arm-none-eabi binutils-arm-none-eabi libusb-1.0-0 libusb-1.0-0-dev libopenjp2-7 python3-libgpiod curl libcurl4-openssl-dev libssl-dev liblmdb-dev libsodium-dev zlib1g-dev libjpeg-dev packagekit wireless-tools

# Create main directory if it doesn't exist
mkdir -p "$MAINSAIL_DIR"
cd "$MAINSAIL_DIR"

echo "Installing klipper"
if [ ! -d "klipper" ]; then
    git clone https://github.com/Klipper3d/klipper
else
    echo "Klipper repository already exists, updating..."
    cd klipper && git pull && cd ..
fi

# Create virtual environment only if it doesn't exist
if [ ! -d "$MAINSAIL_DIR/klippy-env" ]; then
    virtualenv -p python3 "$MAINSAIL_DIR/klippy-env"
fi

# Always update pip requirements (idempotent)
$MAINSAIL_DIR/klippy-env/bin/pip install -r $MAINSAIL_DIR/klipper/scripts/klippy-requirements.txt

# Create directory structure (mkdir -p is idempotent)
mkdir -p "$MAINSAIL_DIR/printer_data"/{config,logs,gcodes,systemd,comms}

echo "Cloning klipper configuration repository"
if [ ! -d "klipper-conf" ]; then
    git clone ssh://git@github.com/ndelucca/klipper-conf.git
else
    echo "Klipper configuration repository already exists, updating..."
    cd klipper-conf && git pull && cd ..
fi

echo "Copying printer.cfg from repository"
cp klipper-conf/versions/v1/printer.cfg "$MAINSAIL_DIR/printer_data/config/printer.cfg"

echo "KLIPPER_ARGS='$MAINSAIL_DIR/klipper/klippy/klippy.py $MAINSAIL_DIR/printer_data/config/printer.cfg -l $MAINSAIL_DIR/printer_data/logs/klippy.log -I $MAINSAIL_DIR/printer_data/comms/klippy.serial -a $MAINSAIL_DIR/printer_data/comms/klippy.sock'" > "$MAINSAIL_DIR/printer_data/systemd/klipper.env"

echo "Creating klipper systemd service"
sudo mkdir -p /etc/systemd/user
sudo tee /etc/systemd/user/klipper.service > /dev/null <<EOF
[Unit]
Description=Klipper 3D Printer Firmware SV1
Documentation=https://www.klipper3d.org/
After=network-online.target
Wants=udev.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=$USER
RemainAfterExit=yes
WorkingDirectory=$MAINSAIL_DIR/klipper
EnvironmentFile=$MAINSAIL_DIR/printer_data/systemd/klipper.env
ExecStart=$MAINSAIL_DIR/klippy-env/bin/python \$KLIPPER_ARGS
Restart=always
RestartSec=10
EOF

echo "Enabling klipper service"
systemctl --user daemon-reload
if ! systemctl --user is-enabled klipper.service > /dev/null 2>&1; then
    systemctl --user enable klipper.service
else
    echo "Klipper service already enabled"
fi

echo "Installing moonraker"
if [ ! -d "moonraker" ]; then
    git clone https://github.com/Arksine/moonraker.git
else
    echo "Moonraker repository already exists, updating..."
    cd moonraker && git pull && cd ..
fi

# Create virtual environment only if it doesn't exist
if [ ! -d "$MAINSAIL_DIR/moonraker-env" ]; then
    virtualenv -p python3 "$MAINSAIL_DIR/moonraker-env"
fi
# Always update pip requirements (idempotent)
$MAINSAIL_DIR/moonraker-env/bin/pip install -r $MAINSAIL_DIR/moonraker/scripts/moonraker-requirements.txt

echo "MOONRAKER_ARGS='$MAINSAIL_DIR/moonraker/moonraker/moonraker.py -d $MAINSAIL_DIR/printer_data'" > "$MAINSAIL_DIR/printer_data/systemd/moonraker.env"

echo "Creating moonraker configuration"
tee "$MAINSAIL_DIR/printer_data/config/moonraker.conf" > /dev/null <<EOF
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

echo "Creating moonraker systemd service"
sudo tee /etc/systemd/user/moonraker.service > /dev/null <<EOF
[Unit]
Description=Moonraker API Server
Documentation=https://moonraker.readthedocs.io/
After=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=$USER
RemainAfterExit=yes
WorkingDirectory=$MAINSAIL_DIR/moonraker
EnvironmentFile=$MAINSAIL_DIR/printer_data/systemd/moonraker.env
ExecStart=$MAINSAIL_DIR/moonraker-env/bin/python \$MOONRAKER_ARGS
Restart=always
RestartSec=10
EOF

echo "Enabling moonraker service"
systemctl --user daemon-reload
if ! systemctl --user is-enabled moonraker.service > /dev/null 2>&1; then
    systemctl --user enable moonraker.service
else
    echo "Moonraker service already enabled"
fi

echo "Setting PolicyKit rules for moonraker"
$MAINSAIL_DIR/moonraker/scripts/set-policykit-rules.sh || echo "PolicyKit rules installed (service restart failed - expected)"

echo "Downloading mainsail static files"
mkdir -p "$MAINSAIL_DIR/mainsail"
cd "$MAINSAIL_DIR"

# Only download if mainsail directory is empty or doesn't exist
if [ ! -f "mainsail/index.html" ]; then
    echo "Downloading Mainsail web interface..."
    wget -q -O mainsail.zip https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip
    unzip -o mainsail.zip -d mainsail
    rm mainsail.zip
else
    echo "Mainsail web interface already exists, skipping download"
fi

echo "Adding mainsail.local to /etc/hosts"
if ! grep -q "mainsail.local" /etc/hosts; then
    echo "127.0.0.1 mainsail.local" | sudo tee -a /etc/hosts
else
    echo "mainsail.local already exists in /etc/hosts"
fi

echo "Setting user permissions for nginx"
# Check if user is already in www-data group
if ! groups $USER | grep -q www-data; then
    sudo gpasswd -a www-data $USER
    echo "Added $USER to www-data group"
else
    echo "$USER already in www-data group"
fi
sudo chmod g+x $HOME

echo "Starting services"
systemctl --user start klipper || echo "Klipper service may already be running"
systemctl --user start moonraker || echo "Moonraker service may already be running"


