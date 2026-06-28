#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=../vars.sh
source "$(dirname "${BASH_SOURCE[0]}")/../vars.sh"   # provee DOTFILES_DIR, TIMEZONE
STOW_DIR="${DOTFILES_DIR}"

# --- Renderizar configs con template antes de stowear ----------------------
# Varios configs se generan desde un template `.in` para que los valores
# específicos de la máquina o duplicados vengan de vars.sh (única fuente de
# verdad) en lugar de estar hardcodeados. Todo output generado está git-ignored;
# solo el `.in` se versiona.
resolve_hwmon() {
    local want d name f
    for want in k10temp coretemp; do
        for d in /sys/class/hwmon/hwmon*; do
            [[ -r "${d}/name" ]] || continue
            read -r name < "${d}/name" || continue
            if [[ "${name}" == "${want}" ]]; then
                f=$(find "${d}" -maxdepth 1 -name 'temp*_input' 2>/dev/null | sort | head -n1)
                [[ -n "${f}" ]] && { echo "${f}"; return 0; }
            fi
        done
    done
    # Fallback: primer input de temperatura disponible en el sistema.
    find /sys/class/hwmon/hwmon*/ -maxdepth 1 -name 'temp*_input' 2>/dev/null | sort | head -n1
}

# render TEMPLATE OUTPUT 'sed-expr' ['sed-expr' ...]
# Aplica las expresiones sed -e dadas a TEMPLATE, escribiendo OUTPUT. No hace nada
# (con un aviso) si falta el template, así los renames no rompen el bootstrap.
render() {
    local template="$1" output="$2"; shift 2
    if [[ ! -f "${template}" ]]; then
        echo "Skip render: ${template} not found"
        return 0
    fi
    local args=() expr
    for expr in "$@"; do args+=(-e "${expr}"); done
    sed "${args[@]}" "${template}" > "${output}"
}

CONFIG_DIR="${STOW_DIR}/.config"

# waybar: timezone desde vars.sh; ruta del sensor de temperatura resuelta por nombre
# del sensor en lugar de un índice hwmon fijo y frágil.
HWMON_PATH="$(resolve_hwmon)"
echo "Rendering waybar config (timezone=${TIMEZONE}, hwmon=${HWMON_PATH:-none})"
render "${CONFIG_DIR}/waybar/config.jsonc.in" "${CONFIG_DIR}/waybar/config.jsonc" \
    "s|@TIMEZONE@|${TIMEZONE}|g" \
    "s|@HWMON_PATH@|${HWMON_PATH}|g"

# wlsunset (luz nocturna): geolocalización desde vars.sh.
echo "Rendering sway night-light config (lat=${LATITUDE}, lon=${LONGITUDE})"
render "${CONFIG_DIR}/sway/config.d/10-wlsunset.conf.in" "${CONFIG_DIR}/sway/config.d/10-wlsunset.conf" \
    "s|@LATITUDE@|${LATITUDE}|g" \
    "s|@LONGITUDE@|${LONGITUDE}|g"

# kanshi: offset del panel del perfil docked desde vars.sh.
echo "Rendering kanshi config (dock left width=${DOCK_LEFT_WIDTH})"
render "${CONFIG_DIR}/kanshi/config.in" "${CONFIG_DIR}/kanshi/config" \
    "s|@DOCK_LEFT_WIDTH@|${DOCK_LEFT_WIDTH}|g"

# Zed reescribe settings.json en runtime (p. ej. agrega ssh_connections cuando abrís
# un proyecto remoto), así que versionarlo directo ensuciaría el repo. Versionamos solo
# settings.json.in y generamos el settings.json (git-ignored) a partir de él; como el
# archivo generado es el target del symlink, las ediciones en runtime de Zed caen en la
# copia ignorada y quedan fuera de git. El `*` de jq hace deep-merge del template POR
# ENCIMA del archivo generado previo (gana el template), así los settings curados se
# aplican siempre mientras que las claves que solo escribió Zed (ssh_connections, ajustes
# de UI) sobreviven entre corridas. Ambos archivos deben ser JSON plano (sin comentarios)
# para jq; si alguna vez el archivo generado no es JSON válido, caemos en sobrescribirlo
# desde el template en lugar de abortar el bootstrap.
ZED_DIR="${STOW_DIR}/.config/zed"
if [[ -f "${ZED_DIR}/settings.json.in" ]]; then
    echo "Rendering zed settings.json (jq deep-merge template over generated)"
    gen="${ZED_DIR}/settings.json"
    [[ -f "${gen}" ]] || echo '{}' > "${gen}"
    tmp="$(mktemp)"
    if jq -s '.[0] * .[1]' "${gen}" "${ZED_DIR}/settings.json.in" > "${tmp}" 2>/dev/null; then
        mv "${tmp}" "${gen}"
    else
        echo "  generated settings.json was not valid JSON; overwriting from template"
        cp "${ZED_DIR}/settings.json.in" "${gen}"
        rm -f "${tmp}"
    fi
fi

# --- Limpiar symlinks obsoletos dejados por dotfiles renombrados/eliminados -
# stow -R no elimina los links cuyo origen ya no existe en el paquete
# (p. ej. un archivo .bashrc.d renombrado). Borra cualquier symlink roto que
# apunte de vuelta a este repo para que los renames/eliminaciones se reflejen.
for pkg in .bashrc.d .config .local; do
    [[ -d "${HOME}/${pkg}" ]] || continue
    while IFS= read -r link; do
        target="$(readlink -m "${link}")"
        if [[ "${target}" == "${STOW_DIR}/"* && ! -e "${link}" ]]; then
            echo "Removing stale symlink: ${link}"
            rm -f "${link}"
        fi
    done < <(find "${HOME}/${pkg}" -type l)
done

# --- Stow de los dotfiles ---------------------------------------------------
# --no-folding symlinkea los archivos individualmente (dirs reales) en lugar de
# foldear directorios enteros — así los archivos que las apps escriben en
# ~/.config quedan fuera del repo.
# -R (restow) reaplica limpio en una máquina ya configurada.
for pkg in .bashrc.d .config .local; do
    mkdir -p "${HOME}/${pkg}"
    stow -R --no-folding -d "${STOW_DIR}" -t "${HOME}/${pkg}" "${pkg}"
done
