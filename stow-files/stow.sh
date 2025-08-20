#!/usr/bin/env bash
set -euo pipefail

# Simple stow wrapper - no sudo logic, just runs stow
# Usage: stow-helper.sh <operation> <package> <target_dir>

operation="$1"
package="$2" 
target_dir="$3"

# Run stow command
stow $operation -t "$target_dir" "$package"

# Reload systemd if target is root and systemctl is available
if [[ "$target_dir" == "/" ]] && command -v systemctl &>/dev/null; then
    systemctl daemon-reload 2>/dev/null || true
fi