#!/usr/bin/env bash
set -euo pipefail

# Simple stow wrapper - no sudo logic, just runs stow
# Usage: stow.sh <operation> <package> <target_dir>

operation="$1"
package="$2" 
target_dir="$3"

log() {
    echo "[stow] $*" >&2
}

# Create directory structure before stow to ensure only files are symlinked
create_directory_structure() {
    log "Creating directory structure for package '$package'"
    
    # Find all directories in the package and create them in target
    find "$package" -type d | while read -r dir; do
        local relative_path="${dir#$package}"
        local target_path="$target_dir$relative_path"
        
        if [[ ! -d "$target_path" ]]; then
            mkdir -p "$target_path"
        fi
    done
}

# Only create directories for install operations (not remove)
if [[ "$operation" != "-D" ]]; then
    create_directory_structure
fi

# Run stow command
log "Running: stow $operation -t $target_dir $package"
stow $operation -t "$target_dir" "$package"

# Reload systemd if target is root and systemctl is available
if [[ "$target_dir" == "/" ]] && command -v systemctl &>/dev/null; then
    systemctl daemon-reload 2>/dev/null || true
fi