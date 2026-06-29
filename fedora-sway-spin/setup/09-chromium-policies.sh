#!/usr/bin/env bash

set -euo pipefail

# Configura Chromium de forma declarativa vía enterprise policies. Es el ÚNICO mecanismo
# de Chromium que es declarativo, idempotente y overwrite-safe: Preferences/Local State
# del perfil los reescribe el browser en runtime, así que no se versionan.
#
# Dos niveles:
#   managed/     -> políticas forzadas (grisadas en chrome://settings). Acá va lo de
#                  privacidad / anti-nag, que queremos fijo siempre.
#   recommended/ -> defaults que el usuario PUEDE cambiar en la UI. Acá va inicio/homepage
#                  y la barra de bookmarks (off => visible solo en la pestaña nueva vacía).
#
# El sync de cuenta Google NO es controlable: Google lo deshabilitó en todos los builds de
# Chromium en 2021. Si alguna vez se necesita sync real, hay que sumar Google Chrome aparte.

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/chromium-policies"

# Detecta el dir base de políticas: Fedora usa /etc/chromium; otras distros
# /etc/chromium-browser. En Fedora el RPM de chromium (instalado vía packages.txt) ya crea
# /etc/chromium/policies, así que ese es el default.
detect_policy_base() {
    local d
    for d in /etc/chromium /etc/chromium-browser; do
        [[ -d "${d}/policies" ]] && { echo "${d}/policies"; return 0; }
    done
    echo "/etc/chromium/policies"
}

# Valida con jq e instala un JSON de política en <base>/<tier>/nd-policies.json.
# Nombre propio para NO pisar el disable-ai.json que trae el RPM de Fedora (coexisten).
# Validamos antes porque Chromium ignora un JSON inválido EN SILENCIO: mejor abortar que
# dejar políticas que parecen aplicadas pero no.
install_policy() {
    local src="$1" base="$2" tier="$3"
    [[ -f "${src}" ]] || { echo "Skip: ${src} no existe"; return 0; }
    if ! jq -e . "${src}" >/dev/null 2>&1; then
        echo "ERROR: ${src} no es JSON válido; no se instala." >&2
        return 1
    fi
    sudo install -d -m 0755 "${base}/${tier}"
    sudo install -m 0644 "${src}" "${base}/${tier}/nd-policies.json"
    echo "Instalada política ${tier}: ${base}/${tier}/nd-policies.json"
}

POLICY_BASE="$(detect_policy_base)"
echo "Instalando políticas de Chromium en ${POLICY_BASE}"
install_policy "${SRC_DIR}/managed.json"     "${POLICY_BASE}" "managed"
install_policy "${SRC_DIR}/recommended.json" "${POLICY_BASE}" "recommended"

echo "Listo. Verificá en chrome://policy (botón 'Reload policies')."
