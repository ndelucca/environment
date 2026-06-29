# shellcheck shell=bash
# eza (ls moderno): íconos Nerd Font + colores + directorios primero. `ls` pelado se deja
# como GNU ls a propósito (scripts/memoria muscular); solo se repuntan los listados a mano.
alias ll='eza -l --icons=auto --group-directories-first'
alias la='eza -la --icons=auto --group-directories-first'
alias l='eza --icons=auto --group-directories-first'

# IP pública vía nd-public-ip (única fuente de la lista de servicios) + IP local.
alias myip='printf "external: %s\nlocal:    %s\n" "$(nd-public-ip show)" "$(hostname -I)"'

