#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_SCRIPT="$SCRIPT_DIR/stow.sh"
BACKUP_SCRIPT="$SCRIPT_DIR/backup.sh"

# Simple logging functions
log() { 
    echo "[$(basename "$0")] $*" >&2
}

die() { 
    log "ERROR: $*"
    exit 1
}

# Run stow install or remove operation
stow_op() {
    local operation="$1"
    local package="$2"
    
    # Validate inputs
    if [[ -z "$package" ]]; then
        die "Package required"
    fi
    
    if [[ ! -d "$package" ]]; then
        die "Package '$package' not found"
    fi
    
    # Execute stow operation based on package type
    case "$package" in
        user)
            log "Running stow $operation for $package -> \$HOME"
            "$STOW_SCRIPT" "$operation" "$package" "$HOME"
            ;;
        system)
            log "Running stow $operation for $package -> / (requires sudo)"
            sudo "$STOW_SCRIPT" "$operation" "$package" "/"
            ;;
        *)
            die "Unknown package: $package"
            ;;
    esac
}

# Backup conflicting files
backup() {
    local package="$1"
    
    # Validate inputs
    if [[ -z "$package" ]]; then
        die "Package required"
    fi
    
    if [[ ! -d "$package" ]]; then
        die "Package '$package' not found"
    fi
    
    # Execute backup based on package type
    case "$package" in
        user)
            "$BACKUP_SCRIPT" backup "$package" "$HOME"
            ;;
        system)
            sudo "$BACKUP_SCRIPT" backup "$package" "/"
            ;;
        *)
            die "Unknown package: $package"
            ;;
    esac
}

# Restore all backup files
restore() {
    log "Restoring backup files..."
    
    # Restore user and system backups
    "$BACKUP_SCRIPT" restore "" "$HOME" 
    sudo "$BACKUP_SCRIPT" restore "" "/"
    
    # Reload systemd after restore
    sudo systemctl daemon-reload 2>/dev/null || systemctl daemon-reload 2>/dev/null || true
}


# Show help
help() {
    cat << EOF
Usage: $(basename "$0") <install|remove|backup|restore> [package]

Simplified dotfiles management using GNU Stow.

Commands:
  install <pkg>   Install package (user|system)
  remove <pkg>    Remove package (user|system)  
  backup <pkg>    Backup conflicting files
  restore         Restore all .bak files

Packages:
  user     User config files (-> \$HOME)
  system   System config files (-> /, needs sudo)

Examples:
  $(basename "$0") install user
  $(basename "$0") backup system
  $(basename "$0") restore
EOF
}

# Main command dispatch
command="${1:-help}"
package="${2:-}"

case "$command" in
    install)
        stow_op "" "$package"
        ;;
    remove)
        stow_op "-D" "$package"
        ;;
    backup)
        backup "$package"
        ;;
    restore)
        restore
        ;;
    help|--help|-h|*)
        help
        ;;
esac