#!/bin/bash

set -e

sudo apt install openvpn

VPN_FILE="vpn.7z"
DEST_DIR="/etc/openvpn/client"

if [ ! -f "$VPN_FILE" ]; then
    echo "Error: No se encontró el archivo $VPN_FILE"
    exit 1
fi

echo "Creando directorio destino: $DEST_DIR"
sudo mkdir -p "$DEST_DIR"

echo "🔐 Ingresa la contraseña del archivo 7z:"
read -s PASSWORD
echo

if [ -z "$PASSWORD" ]; then
    echo "Error: No se ingresó contraseña"
    exit 1
fi

echo "📦 Extrayendo archivo a $DEST_DIR..."
if sudo 7z x "$VPN_FILE" -o"$DEST_DIR" -p"$PASSWORD" -y; then
    echo "Extracción completada exitosamente"
    echo
    echo "Archivos extraídos en $DEST_DIR:"
    sudo ls -la "$DEST_DIR"
else
    echo "Error durante la extracción"
    echo "   Verifica que la contraseña sea correcta"
    exit 1
fi
