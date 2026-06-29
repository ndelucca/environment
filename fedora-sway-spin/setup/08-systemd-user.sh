#!/usr/bin/env bash

set -euo pipefail

# Habilita las tareas personales croneadas vía systemd **user** units.
#
# Las units viven versionadas en dotfiles/.config/systemd/user/ y las symlinkea
# stow junto con el resto de .config (04-stow.sh). stow deja los archivos, pero
# habilitarlos (crear los symlinks en timers.target.wants/) es trabajo de
# systemctl, así que va acá, después del stow.
#
# Convención del mini-sistema: se habilita cualquier `nd-*.timer` que aparezca
# en el directorio. Agregar una tarea = soltar su .service + .timer con prefijo
# `nd-` y re-correr el bootstrap.

UNIT_DIR="${HOME}/.config/systemd/user"

# Guard: sin sesión de usuario (p. ej. bootstrap headless) no hay user manager
# al que hablarle. Avisar y salir 0 para no romper el bootstrap; los timers
# quedan listos para la próxima corrida dentro de una sesión gráfica.
if ! systemctl --user show-environment >/dev/null 2>&1; then
    echo "systemd --user no disponible (¿sin sesión de usuario?); salteando enable de timers."
    exit 0
fi

systemctl --user daemon-reload

shopt -s nullglob
timers=("${UNIT_DIR}"/nd-*.timer)
shopt -u nullglob

if ((${#timers[@]} == 0)); then
    echo "No hay timers nd-*.timer en ${UNIT_DIR}. Nada que habilitar."
    exit 0
fi

# enable --now es idempotente: re-habilitar/re-arrancar un timer ya activo es
# inofensivo, así reaplicar el bootstrap en una máquina configurada no molesta.
for timer in "${timers[@]}"; do
    name="$(basename "${timer}")"
    echo "Habilitando ${name}"
    systemctl --user enable --now "${name}"
done
