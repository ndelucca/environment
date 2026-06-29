#!/usr/bin/env bash

set -euo pipefail

# Gestión de energía: red de seguridad de batería para esta laptop. Por defecto el Spin
# deja CriticalPowerAction=Auto (suele terminar en apagón en seco). En vez de eso, al
# llegar al nivel de acción suspendemos, para no perder la sesión.
#
# UPower 1.91+ soporta drop-ins en /etc/UPower/UPower.conf.d/ (override por archivo, sin
# forkear el UPower.conf del sistema — mismo espíritu que el resto del setup). El nombre
# debe matchear ^[0-9][0-9]-...\.conf.

echo "Configurando red de seguridad de batería (UPower drop-in)"

sudo install -d /etc/UPower/UPower.conf.d
sudo tee /etc/UPower/UPower.conf.d/90-ndelucca.conf >/dev/null <<'EOF'
[UPower]
# Al llegar al nivel de acción (PercentageAction), suspender en vez del Auto del Spin.
# Evita el apagón en seco / pérdida de sesión en esta laptop vieja.
CriticalPowerAction=Suspend
# Suspend NO persiste a disco: si la batería se agota suspendida, se pierde el estado.
# UPower lo considera "risky" y exige habilitarlo explícitamente.
AllowRiskyCriticalPowerAction=true
# Margen para batería degradada que sub-reporta: disparar la acción al 5% (default 2%).
PercentageAction=5.0
EOF

# Aplica sin reboot. Si corre sin systemd a mano (bootstrap headless), no es fatal.
sudo systemctl restart upower 2>/dev/null || \
    echo "  (no se pudo reiniciar upower ahora; aplica al próximo arranque)"
