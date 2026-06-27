#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=../vars.sh
source "$(dirname "${BASH_SOURCE[0]}")/../vars.sh"   # provides SETUP_DIR
REMOVE_FILE="${SETUP_DIR}/remove-packages.txt"

# Read the wanted-gone list (skip comments/blank lines).
mapfile -t WANTED_GONE < <(grep -vE '^\s*(#|$)' "${REMOVE_FILE}")

# Only act on packages actually installed, so this is idempotent and dnf doesn't
# error out on already-absent ones.
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
