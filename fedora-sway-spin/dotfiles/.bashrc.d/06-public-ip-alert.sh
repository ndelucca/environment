# Public IP change monitor
# Requires: ~/.local/bin/nd-public-ip
#
# Shows alert on terminal open if public IP changed.
# Run 'nd-public-ip update' to accept new IP and clear alert.

_ND_IP_SCRIPT="${HOME}/.local/bin/nd-public-ip"
_ND_IP_CACHE="${HOME}/.cache/nd-public-ip"
_ND_IP_BOOT_FLAG="${_ND_IP_CACHE}/boot_check_done"

# Run check on first terminal of the session (boot check)
if [[ -x "$_ND_IP_SCRIPT" ]]; then
    # Check if we've already done boot check (file younger than system uptime)
    _uptime_seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null || echo 0)
    _boot_check_age=$(($(date +%s) - $(stat -c %Y "$_ND_IP_BOOT_FLAG" 2>/dev/null || echo 0)))

    if [[ $_boot_check_age -gt $_uptime_seconds ]]; then
        # First shell since boot, run check silently
        "$_ND_IP_SCRIPT" check >/dev/null 2>&1
        mkdir -p "$_ND_IP_CACHE"
        touch "$_ND_IP_BOOT_FLAG"
    fi

    # Show alert if IP changed
    if [[ -f "${_ND_IP_CACHE}/alert" ]]; then
        "$_ND_IP_SCRIPT" alert
    fi
fi

unset _ND_IP_SCRIPT _ND_IP_CACHE _ND_IP_BOOT_FLAG _uptime_seconds _boot_check_age
