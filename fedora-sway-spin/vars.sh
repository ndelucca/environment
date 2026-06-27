#!/usr/bin/env bash
#
# Single source of truth for the repo layout and for values that would
# otherwise be duplicated across setup scripts and templates.
#
# Sourced (not executed). Because it derives paths from its OWN location via
# BASH_SOURCE, every script that sources it shares the same paths — no need to
# repeat the discovery recipe in each script. Consumers only need:
#     source "$(dirname "${BASH_SOURCE[0]}")/<...>/vars.sh"

# --- Repo layout (discovered once, here) ---
SWAY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # fedora-sway-spin/
REPO_DIR="$(cd "${SWAY_DIR}/.." && pwd)"                    # repo root
SETUP_DIR="${SWAY_DIR}/setup"
DOTFILES_DIR="${SWAY_DIR}/dotfiles"

# --- User / deployment values (versioned on purpose, defined once) ---
TIMEZONE="America/Argentina/Buenos_Aires"

# Geolocation for wlsunset (night light). Rendered into the generated
# sway/config.d/10-wlsunset.conf by 05-stow.sh. Buenos Aires.
LATITUDE="-34.6"
LONGITUDE="-58.4"

# X offset (px) of the internal panel in kanshi's `docked` profile: it equals the
# width of the external monitor placed to its LEFT (HDMI-A-1). kanshi can't do
# arithmetic or relative positioning, so the value lives here instead of being
# hardcoded in kanshi/config. Adjust if the external monitor's width differs.
DOCK_LEFT_WIDTH="1920"

GIT_NAME="ndelucca"
GIT_EMAIL="ndelucca@protonmail.com"
