#!/usr/bin/env bash
# shellcheck shell=bash
# fzf: keybindings + completado. Se carga después de 03-completions.sh (orden de glob de
# ~/.bashrc.d/*), así los binds de fzf quedan por encima de los defaults de readline.
#
# Qué agrega:
#   Ctrl-R  -> búsqueda difusa a pantalla completa sobre el historial (HISTSIZE grande).
#   Ctrl-T  -> insertar ruta de archivo (fuzzy, vía fd) en la línea de comando.
#   Alt-C   -> cd a un subdirectorio (fuzzy, vía fd).
#   **<tab> -> completado difuso (cd **<tab>, ssh **<tab>, etc.).

# Solo interactivas.
[[ $- != *i* ]] && return

# Archivos del paquete fzf de Fedora (/usr/share/fzf/shell). Guardas por si una versión
# futura mueve las rutas: sin el archivo, no rompe la shell.
for _fzf in \
    /usr/share/fzf/shell/key-bindings.bash \
    /usr/share/fzf/shell/completion.bash; do
    # shellcheck source=/dev/null
    [[ -f "${_fzf}" ]] && source "${_fzf}"
done
unset _fzf

# Usar fd (paquete fd-find; binario `fd`) como fuente: respeta .gitignore, salta .git y
# es más rápido que find. Si fd no está, fzf cae a su walker interno igual.
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
fi

# Acento verde #387838 del dominio Desktop+Terminal (igual que foot/tmux/rofi/prompt).
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline
--color=fg+:#ffffff,bg+:#1a1a1a,hl:#387838,hl+:#6cb66c
--color=prompt:#387838,pointer:#387838,marker:#387838,spinner:#387838,header:#387838'
