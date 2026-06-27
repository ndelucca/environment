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
# Per-app logos shipped in the repo and deployed via stow to this path
# (dotfiles/.local/share/icons/webapps/<Name>.png). The default GTK/Adwaita
# theme has no per-service icons, so we reference the PNGs by absolute path.
# Fallback to the chromium icon (named chromium-browser on Fedora, NOT chromium)
# if a logo is missing.
ICON_DIR="$HOME/.local/share/icons/webapps"
FALLBACK_ICON="chromium-browser"

create_webapp() {
    local name="$1"
    local url="$2"
    local desktop_file="$WEBAPPS_DIR/${name}.desktop"

    local icon="${ICON_DIR}/${name}.png"
    [ -f "$icon" ] || icon="$FALLBACK_ICON"

    echo "Creating or updating: $name"
    # NOTE: under Wayland, Chromium derives the app_id from the URL
    # (chrome-<host>__-Default) and ignores --class for matching, so Sway's
    # `assign` rules in ~/.config/sway/config match by host, not by this name.
    # --class only affects the WM_CLASS used under XWayland.
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

update-desktop-database "$WEBAPPS_DIR" >/dev/null 2>&1 || true
