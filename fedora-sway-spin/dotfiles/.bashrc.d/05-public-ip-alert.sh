# Monitor de cambios de IP pública.
# Requiere: ~/.local/bin/nd-public-ip
#
# Muestra una alerta al abrir la terminal si la IP pública cambió.
# Correr 'nd-public-ip update' para aceptar la nueva IP y limpiar la alerta.

_ND_IP_SCRIPT="${HOME}/.local/bin/nd-public-ip"
_ND_IP_CACHE="${HOME}/.cache/nd-public-ip"
_ND_IP_BOOT_FLAG="${_ND_IP_CACHE}/boot_check_done"

# Correr el chequeo en la primera terminal de la sesión (chequeo de boot).
if [[ -x "$_ND_IP_SCRIPT" ]]; then
    # Ver si ya hicimos el chequeo de boot (flag más nuevo que el uptime del sistema).
    _uptime_seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null || echo 0)
    _boot_check_age=$(($(date +%s) - $(stat -c %Y "$_ND_IP_BOOT_FLAG" 2>/dev/null || echo 0)))

    if [[ $_boot_check_age -gt $_uptime_seconds ]]; then
        # Primer shell desde el boot: correr el chequeo en silencio.
        "$_ND_IP_SCRIPT" check >/dev/null 2>&1
        mkdir -p "$_ND_IP_CACHE"
        touch "$_ND_IP_BOOT_FLAG"
    fi

    # Mostrar la alerta si la IP cambió.
    if [[ -f "${_ND_IP_CACHE}/alert" ]]; then
        "$_ND_IP_SCRIPT" alert
    fi
fi

unset _ND_IP_SCRIPT _ND_IP_CACHE _ND_IP_BOOT_FLAG _uptime_seconds _boot_check_age
