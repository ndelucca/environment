#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=../vars.sh
source "$(dirname "${BASH_SOURCE[0]}")/../vars.sh"   # provee SETUP_DIR
REMOVE_FILE="${SETUP_DIR}/remove-packages.txt"

# Leer la lista de paquetes a sacar (saltea comentarios/líneas en blanco).
mapfile -t WANTED_GONE < <(grep -vE '^\s*(#|$)' "${REMOVE_FILE}")

# Actuar solo sobre paquetes realmente instalados, así esto es idempotente y dnf no
# falla con los que ya no están.
TO_REMOVE=()
for pkg in "${WANTED_GONE[@]}"; do
    if rpm -q "${pkg}" &>/dev/null; then
        TO_REMOVE+=("${pkg}")
    fi
done

if ((${#TO_REMOVE[@]})); then
    echo "Removing unwanted packages: ${TO_REMOVE[*]}"
    sudo dnf remove -y "${TO_REMOVE[@]}"
else
    echo "No unwanted packages installed. Nothing to remove."
fi
