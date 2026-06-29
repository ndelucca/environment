# shellcheck shell=bash
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# IP pública vía nd-public-ip (única fuente de la lista de servicios) + IP local.
alias myip='printf "external: %s\nlocal:    %s\n" "$(nd-public-ip show)" "$(hostname -I)"'

