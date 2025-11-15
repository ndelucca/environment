#!/usr/bin/env bash

set -euo pipefail

WEBAPPS_DIR="$HOME/.local/share/applications/webapps"
mkdir -p "$WEBAPPS_DIR"

declare -A WEBAPPS=(
    [Spotify]="https://open.spotify.com"
    [Tidal]="https://listen.tidal.com"
    [Teams]="https://teams.microsoft.com"
    [ChatGPT]="https://chat.openai.com"
    [Discord]="https://discord.com/app"
    [WhatsApp]="https://web.whatsapp.com"
    [Gmail]="https://mail.google.com"
)

CHROMIUM_BIN="${CHROMIUM_BIN:-chromium-browser}"
DEFAULT_ICON="chromium"

create_webapp() {
    local name="$1"
    local url="$2"
    local desktop_file="$WEBAPPS_DIR/${name}.desktop"

    echo "Creating or updating: $name"
    tee "$desktop_file" >/dev/null <<EOF
[Desktop Entry]
Name=${name}
Exec=${CHROMIUM_BIN} --app="${url}" --class=${name}
Icon=${DEFAULT_ICON}
Type=Application
Categories=WebApps;
EOF
}

for app in "${!WEBAPPS[@]}"; do
    create_webapp "$app" "${WEBAPPS[$app]}"
done

update-desktop-database "$WEBAPPS_DIR" >/dev/null 2>&1 || true
