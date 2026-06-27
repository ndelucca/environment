#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=../vars.sh
source "$(dirname "${BASH_SOURCE[0]}")/../vars.sh"   # provides DOTFILES_DIR, TIMEZONE
STOW_DIR="${DOTFILES_DIR}"

# --- Render templated configs before stowing -------------------------------
# waybar's config.jsonc is generated from config.jsonc.in: the timezone comes
# from vars.sh (single source of truth) and the temperature sensor path is
# resolved by sensor name instead of a fragile fixed hwmon index. The generated
# config.jsonc is git-ignored.
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
    # Fallback: first temperature input available on the system.
    find /sys/class/hwmon/hwmon*/ -maxdepth 1 -name 'temp*_input' 2>/dev/null | sort | head -n1
}

WAYBAR_DIR="${STOW_DIR}/.config/waybar"
if [[ -f "${WAYBAR_DIR}/config.jsonc.in" ]]; then
    HWMON_PATH="$(resolve_hwmon)"
    echo "Rendering waybar config (timezone=${TIMEZONE}, hwmon=${HWMON_PATH:-none})"
    sed -e "s|@TIMEZONE@|${TIMEZONE}|g" \
        -e "s|@HWMON_PATH@|${HWMON_PATH}|g" \
        "${WAYBAR_DIR}/config.jsonc.in" > "${WAYBAR_DIR}/config.jsonc"
fi

# --- Clean stale symlinks left by renamed/removed dotfiles ------------------
# stow -R does not remove links whose source no longer exists in the package
# (e.g. a renamed .bashrc.d file). Drop any broken symlink that points back
# into this repo so renames/removals are reflected.
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

# --- Stow dotfiles ----------------------------------------------------------
# --no-folding symlinks files individually (real dirs) instead of folding whole
# directories — so files apps write into ~/.config stay out of the repo.
# -R (restow) re-applies cleanly on an already-configured machine.
for pkg in .bashrc.d .config .local; do
    mkdir -p "${HOME}/${pkg}"
    stow -R --no-folding -d "${STOW_DIR}" -t "${HOME}/${pkg}" "${pkg}"
done
