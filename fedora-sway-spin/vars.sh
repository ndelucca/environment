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

GIT_NAME="ndelucca"
GIT_EMAIL="ndelucca@protonmail.com"
