#!/usr/bin/env bash
set -euo pipefail

# Backup utility for dotfiles management
# Usage: backup.sh <backup|restore> <package> <target_dir>

operation="$1"
package="$2"
target_dir="$3"

log() {
    echo "[backup] $*" >&2
}

case "$operation" in
    backup)
        # Find and backup conflicting files
        backed_up=0
        find "$package" -type f | while read -r file; do
            # Convert package file path to target file path
            target="$target_dir/${file#$package/}"
            
            # Only backup if target exists and is NOT a symlink
            if [[ -e "$target" && ! -L "$target" ]]; then
                log "Backing up $target"
                mv "$target" "$target.bak"
                ((backed_up++))
            fi
        done
        log "Backup complete. $backed_up files backed up"
        ;;
        
    restore)
        # Restore all .bak files in target directory
        restored=0
        find "$target_dir" -name "*.bak" -type f 2>/dev/null | while read -r backup_file; do
            original_file="${backup_file%.bak}"
            log "Restoring $backup_file -> $original_file"
            mv "$backup_file" "$original_file"
            ((restored++))
        done
        
        if [[ $restored -gt 0 ]]; then
            log "Restored $restored backup files"
        else
            log "No backup files found in $target_dir"
        fi
        ;;
        
    *)
        echo "Usage: $0 <backup|restore> <package> <target_dir>" >&2
        exit 1
        ;;
esac