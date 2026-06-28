#!/usr/bin/env bash
#
# Única fuente de verdad (SSOT) para el layout del repo y para valores que de otra
# forma quedarían duplicados entre los scripts de setup y los templates.
#
# Se hace source (no se ejecuta). Como deriva las rutas desde su PROPIA ubicación vía
# BASH_SOURCE, todo script que lo haga source comparte las mismas rutas — no hace falta
# repetir la receta de descubrimiento en cada script. Los consumidores solo necesitan:
#     source "$(dirname "${BASH_SOURCE[0]}")/<...>/vars.sh"

# Las variables las consumen los scripts que hacen source, no este archivo: SC2034
# ("appears unused") es un falso positivo acá.
# shellcheck disable=SC2034

# --- Layout del repo (descubierto una sola vez, acá) ---
SWAY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # fedora-sway-spin/
REPO_DIR="$(cd "${SWAY_DIR}/.." && pwd)"                    # raíz del repo
SETUP_DIR="${SWAY_DIR}/setup"
DOTFILES_DIR="${SWAY_DIR}/dotfiles"

# --- Valores de usuario / deployment (versionados a propósito, definidos una vez) ---
TIMEZONE="America/Argentina/Buenos_Aires"
LOCALE="en_US.UTF-8"

# Layout de teclado (la alternativa a la que cambia el usuario: "latam"). KEYMAP es el
# keymap de consola (lo consume 01-locale-datetime-keyboard.sh vía localectl). KEYMAP_X11
# es el layout de Wayland/XWayland: lo consume tanto localectl (default del sistema) como
# el generado sway/config.d/10-keyboard.conf (override de la sesión) renderizado por
# 05-stow.sh. KEYMAP_X11_VARIANT es la variante xkb opcional (vacío = sin variante).
KEYMAP="us-euro"
KEYMAP_X11="eu"
KEYMAP_X11_VARIANT=""

# Geolocalización para wlsunset (luz nocturna). Se renderiza en el generado
# sway/config.d/10-wlsunset.conf por 05-stow.sh. Buenos Aires.
LATITUDE="-34.6"
LONGITUDE="-58.4"

# Offset X (px) del panel interno en el perfil `docked` de kanshi: equivale al
# ancho del monitor externo ubicado a su IZQUIERDA (HDMI-A-1). kanshi no puede hacer
# aritmética ni posicionamiento relativo, así que el valor vive acá en lugar de estar
# hardcodeado en kanshi/config. Ajustar si el ancho del monitor externo difiere.
DOCK_LEFT_WIDTH="1920"

GIT_NAME="ndelucca"
GIT_EMAIL="ndelucca@protonmail.com"

# Cuenta de GitHub dueña del remote origin de este repo (la usa 00-git-bash.sh para pasar
# origin a SSH). Separada de GIT_NAME porque el nombre de autor de commits y el handle de
# la cuenta son hechos distintos, aunque hoy coincidan.
GITHUB_USER="ndelucca"
