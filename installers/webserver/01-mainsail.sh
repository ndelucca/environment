#!/usr/bin/bash

set -e

MAINSAIL_DIR="/var/www/mainsail.local"

echo "Installing dependencies"
sudo apt install -y python3-virtualenv python3-dev libffi-dev build-essential libncurses-dev avrdude gcc-avr binutils-avr avr-libc stm32flash dfu-util libnewlib-arm-none-eabi gcc-arm-none-eabi binutils-arm-none-eabi libusb-1.0-0 libusb-1.0-0-dev libopenjp2-7 python3-libgpiod curl libcurl4-openssl-dev libssl-dev liblmdb-dev libsodium-dev zlib1g-dev libjpeg-dev packagekit wireless-tools

echo "Adding www-data user to dialout group for serial access"
sudo usermod -a -G dialout www-data

# Create main directory structure
echo "Creating directory structure in $MAINSAIL_DIR"
sudo mkdir -p "$MAINSAIL_DIR"
sudo mkdir -p "$MAINSAIL_DIR/printer_data"/{config,logs,gcodes,systemd,comms}

# Set ownership to www-data
sudo chown -R www-data:www-data "$MAINSAIL_DIR"

echo "Installing klipper"
if [ ! -d "$MAINSAIL_DIR/klipper" ]; then
    sudo -u www-data git clone https://github.com/Klipper3d/klipper "$MAINSAIL_DIR/klipper"
else
    echo "Klipper repository already exists, updating..."
    cd "$MAINSAIL_DIR/klipper" && sudo -u www-data git pull && cd -
fi

# Create virtual environment only if it doesn't exist
if [ ! -d "$MAINSAIL_DIR/klippy-env" ]; then
    sudo -u www-data virtualenv -p python3 "$MAINSAIL_DIR/klippy-env"
fi

# Always update pip requirements (idempotent)
sudo -u www-data $MAINSAIL_DIR/klippy-env/bin/pip install -r $MAINSAIL_DIR/klipper/scripts/klippy-requirements.txt

echo "Cloning klipper configuration repository"
if [ ! -d "$MAINSAIL_DIR/klipper-conf" ]; then
    sudo -u www-data git clone https://github.com/ndelucca/klipper-conf.git "$MAINSAIL_DIR/klipper-conf"
else
    echo "Klipper configuration repository already exists, updating..."
    cd "$MAINSAIL_DIR/klipper-conf" && sudo -u www-data git pull && cd -
fi

echo "Copying printer.cfg from repository"
sudo -u www-data ln -f -s "$MAINSAIL_DIR/klipper-conf/versions/v1/printer.cfg" "$MAINSAIL_DIR/printer_data/config/printer.cfg"
sudo -u www-data ln -f -s "$MAINSAIL_DIR/klipper-conf/versions/v1/macros.cfg" "$MAINSAIL_DIR/printer_data/config/macros.cfg"

echo "Creating klipper environment file"
sudo -u www-data tee "$MAINSAIL_DIR/printer_data/systemd/klipper.env" > /dev/null <<EOF
KLIPPER_ARGS='$MAINSAIL_DIR/klipper/klippy/klippy.py $MAINSAIL_DIR/printer_data/config/printer.cfg -l $MAINSAIL_DIR/printer_data/logs/klippy.log -I $MAINSAIL_DIR/printer_data/comms/klippy.serial -a $MAINSAIL_DIR/printer_data/comms/klippy.sock'
EOF

echo "Installing moonraker"
if [ ! -d "$MAINSAIL_DIR/moonraker" ]; then
    sudo -u www-data git clone https://github.com/Arksine/moonraker.git "$MAINSAIL_DIR/moonraker"
else
    echo "Moonraker repository already exists, updating..."
    cd "$MAINSAIL_DIR/moonraker" && sudo -u www-data git pull && cd -
fi

# Create virtual environment only if it doesn't exist
if [ ! -d "$MAINSAIL_DIR/moonraker-env" ]; then
    sudo -u www-data virtualenv -p python3 "$MAINSAIL_DIR/moonraker-env"
fi

# Always update pip requirements (idempotent)
sudo -u www-data $MAINSAIL_DIR/moonraker-env/bin/pip install -r $MAINSAIL_DIR/moonraker/scripts/moonraker-requirements.txt

echo "Creating moonraker environment file"
sudo -u www-data tee "$MAINSAIL_DIR/printer_data/systemd/moonraker.env" > /dev/null <<EOF
MOONRAKER_ARGS='$MAINSAIL_DIR/moonraker/moonraker/moonraker.py -d $MAINSAIL_DIR/printer_data'
EOF

echo "Creating moonraker configuration"
sudo -u www-data tee "$MAINSAIL_DIR/printer_data/config/moonraker.conf" > /dev/null <<EOF
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

echo "Downloading mainsail static files"
sudo mkdir -p "$MAINSAIL_DIR/web"
cd "$MAINSAIL_DIR/web"

# Only download if mainsail directory is empty or doesn't exist
if [ ! -f "index.html" ]; then
    echo "Downloading Mainsail web interface..."
    sudo -u www-data wget -q -O mainsail.zip https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip
    sudo -u www-data unzip -o mainsail.zip -d .
    sudo -u www-data rm mainsail.zip
else
    echo "Mainsail web interface already exists, skipping download"
fi

echo "Setting final permissions"
# Ensure proper ownership and permissions
sudo chown -R www-data:www-data "$MAINSAIL_DIR"
sudo chmod -R 755 "$MAINSAIL_DIR"

echo "Adding mainsail.local to /etc/hosts"
if ! grep -q "mainsail.local" /etc/hosts; then
    echo "127.0.0.1 mainsail.local" | sudo tee -a /etc/hosts
else
    echo "mainsail.local already exists in /etc/hosts"
fi

echo "Setting up SSL certificates for HTTPS"
# Check if certificates already exist
if [ ! -f "/etc/ssl/certs/mainsail.local.pem" ] || [ ! -f "/etc/ssl/private/mainsail.local-key.pem" ]; then
    echo "SSL certificates not found, creating new ones with mkcert..."

    # Install mkcert if not available
    if ! command -v mkcert &> /dev/null; then
        echo "Installing mkcert..."
        curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
        chmod +x mkcert-v*-linux-amd64
        sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
    fi

    # Install local CA if not already done
    if [ ! -d "$HOME/.local/share/mkcert" ]; then
        echo "Installing local CA..."
        mkcert -install
    fi

    # Generate certificate for mainsail.local
    echo "Generating SSL certificate for mainsail.local..."
    mkcert mainsail.local

    # Move certificates to system directories
    sudo mkdir -p /etc/ssl/private
    sudo mv mainsail.local.pem /etc/ssl/certs/
    sudo mv mainsail.local-key.pem /etc/ssl/private/
    sudo chmod 644 /etc/ssl/certs/mainsail.local.pem
    sudo chmod 600 /etc/ssl/private/mainsail.local-key.pem
    sudo chown root:root /etc/ssl/certs/mainsail.local.pem
    sudo chown root:ssl-cert /etc/ssl/private/mainsail.local-key.pem

    echo "SSL certificates created and installed successfully"
else
    echo "SSL certificates already exist, skipping creation"
fi

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

echo "Starting services"
sudo systemctl start klipper || echo "Klipper service may already be running"
sudo systemctl start moonraker || echo "Moonraker service may already be running"