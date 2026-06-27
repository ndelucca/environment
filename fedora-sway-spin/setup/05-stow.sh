#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=../vars.sh
source "$(dirname "${BASH_SOURCE[0]}")/../vars.sh"   # provides DOTFILES_DIR, TIMEZONE
STOW_DIR="${DOTFILES_DIR}"

# --- Render templated configs before stowing -------------------------------
# Several configs are generated from a `.in` template so machine-specific or
# duplicated values come from vars.sh (single source of truth) instead of being
# hardcoded. Every generated output is git-ignored; only the `.in` is tracked.
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

# render TEMPLATE OUTPUT 'sed-expr' ['sed-expr' ...]
# Applies the given sed -e expressions to TEMPLATE, writing OUTPUT. No-op (with a
# notice) if the template is missing, so renames don't break the bootstrap.
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

# waybar: timezone from vars.sh; temperature sensor path resolved by sensor name
# instead of a fragile fixed hwmon index.
HWMON_PATH="$(resolve_hwmon)"
echo "Rendering waybar config (timezone=${TIMEZONE}, hwmon=${HWMON_PATH:-none})"
render "${CONFIG_DIR}/waybar/config.jsonc.in" "${CONFIG_DIR}/waybar/config.jsonc" \
    "s|@TIMEZONE@|${TIMEZONE}|g" \
    "s|@HWMON_PATH@|${HWMON_PATH}|g"

# wlsunset (night light): geolocation from vars.sh.
echo "Rendering sway night-light config (lat=${LATITUDE}, lon=${LONGITUDE})"
render "${CONFIG_DIR}/sway/config.d/10-wlsunset.conf.in" "${CONFIG_DIR}/sway/config.d/10-wlsunset.conf" \
    "s|@LATITUDE@|${LATITUDE}|g" \
    "s|@LONGITUDE@|${LONGITUDE}|g"

# kanshi: docked-profile panel offset from vars.sh.
echo "Rendering kanshi config (dock left width=${DOCK_LEFT_WIDTH})"
render "${CONFIG_DIR}/kanshi/config.in" "${CONFIG_DIR}/kanshi/config" \
    "s|@DOCK_LEFT_WIDTH@|${DOCK_LEFT_WIDTH}|g"

# Zed rewrites settings.json at runtime (e.g. appends ssh_connections when you open
# a remote project), so tracking it directly would churn the repo. We track only
# settings.json.in and generate the git-ignored settings.json from it; since the
# generated file is the symlink target, Zed's runtime edits land in the ignored
# copy and stay out of git. jq's `*` deep-merges the template OVER the previously
# generated file (template wins), so curated settings are always applied while keys
# only Zed wrote (ssh_connections, UI tweaks) survive across runs. Both files must
# be plain JSON (no comments) for jq; if the generated file ever isn't valid JSON,
# we fall back to overwriting it from the template instead of aborting the bootstrap.
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
