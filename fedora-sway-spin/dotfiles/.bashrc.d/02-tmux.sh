#!/usr/bin/env bash

# Si no es interactiva, no hacer nada.
[[ $- != *i* ]] && return

# Si la versión de bash es mala, no hacer nada.
((BASH_VERSINFO[0] < 4)) && return

# Salir si la terminal no puede usar colores.
[[ ! "${TERM}" =~ foot ]] && return

if command -v tmux &>>/dev/null \
    && [[ ! "${TERM}" =~ screen ]] \
    && [[ ! "${TERM}" =~ tmux ]] \
    && [[ -z "${TMUX}" ]]; then
    # Decirle a tmux que asuma 256 colores con la opción -2.
    ASSUME_256_COLOR="-2"
    exec tmux ${ASSUME_256_COLOR} new-session -A -s forest
fi
