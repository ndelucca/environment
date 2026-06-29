#!/usr/bin/env bash

set -euo pipefail

WEBAPPS_DIR="$HOME/.local/share/applications/webapps"
mkdir -p "$WEBAPPS_DIR"

declare -A WEBAPPS=(
    [Spotify]="https://open.spotify.com"
    [ChatGPT]="https://chat.openai.com"
    [WhatsApp]="https://web.whatsapp.com"
    [Gmail]="https://mail.google.com"
)

CHROMIUM_BIN="${CHROMIUM_BIN:-chromium-browser}"
# Logos por app que vienen en el repo y se despliegan vía stow a esta ruta
# (dotfiles/.local/share/icons/webapps/<Name>.png). El tema GTK/Adwaita por
# defecto no tiene íconos por servicio, así que referenciamos los PNG por ruta
# absoluta. Si falta un logo, fallback al ícono de chromium (llamado
# chromium-browser en Fedora, NO chromium).
ICON_DIR="$HOME/.local/share/icons/webapps"
FALLBACK_ICON="chromium-browser"

create_webapp() {
    local name="$1"
    local url="$2"
    local desktop_file="$WEBAPPS_DIR/${name}.desktop"

    local icon="${ICON_DIR}/${name}.png"
    [ -f "$icon" ] || icon="$FALLBACK_ICON"

    echo "Creating or updating: $name"
    # NOTA: bajo Wayland, Chromium deriva el app_id desde la URL
    # (chrome-<host>__-Default) e ignora --class para el matcheo, así que las
    # reglas `assign` de Sway en ~/.config/sway/config matchean por host, no por
    # este nombre. --class solo afecta al WM_CLASS usado bajo XWayland.
    tee "$desktop_file" >/dev/null <<EOF
[Desktop Entry]
Name=${name}
Exec=${CHROMIUM_BIN} --app="${url}" --class=${name}
Icon=${icon}
Type=Application
Categories=WebApps;
EOF
}

for app in "${!WEBAPPS[@]}"; do
    create_webapp "$app" "${WEBAPPS[$app]}"
done

# Prune declarativo: borra los .desktop de webapps que ya no están en WEBAPPS (p. ej. al
# sacar un servicio del array), así el dir refleja exactamente la lista y no quedan
# lanzadores muertos en rofi. WEBAPPS_DIR es exclusivo de este script, así que es seguro.
for desktop_file in "$WEBAPPS_DIR"/*.desktop; do
    [ -e "$desktop_file" ] || continue
    name="$(basename "$desktop_file" .desktop)"
    if [[ -z "${WEBAPPS[$name]+x}" ]]; then
        echo "Removing stale webapp: $name"
        rm -f "$desktop_file"
    fi
done
