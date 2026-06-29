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
    # Deliberado: `-A -s forest` attachea a una ÚNICA sesión compartida llamada
    # "forest" (la crea si no existe). O sea, abrir otra ventana de foot NO da un shell
    # fresco: muestra las mismas ventanas/panes de tmux. Si alguna vez se quieren
    # terminales independientes, usar `new-session` sin `-A -s` fijo.
    exec tmux ${ASSUME_256_COLOR} new-session -A -s forest
fi
