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

# Validate package input
validate_package() {
    local package="$1"
    
    if [[ -z "$package" ]]; then
        die "Package required"
    fi
    
    if [[ ! -d "$package" ]]; then
        die "Package '$package' not found"
    fi
    
    case "$package" in
        user|system) ;;
        *) die "Unknown package: $package" ;;
    esac
}

# Execute script with appropriate permissions for package type
run_for_package() {
    local script="$1"
    local package="$2"
    shift 2  # Remove first two args, keep the rest
    
    case "$package" in
        user)
            "$script" "$@" "$HOME"
            ;;
        system)
            sudo "$script" "$@" "/"
            ;;
    esac
}

# Run stow install or remove operation
stow_op() {
    local operation="$1"
    local package="$2"
    
    log "Running stow $operation for $package"
    run_for_package "$STOW_SCRIPT" "$package" "$operation" "$package"
}

# Backup conflicting files
backup() {
    local package="$1"
    
    log "Backing up conflicting files for $package"
    run_for_package "$BACKUP_SCRIPT" "$package" backup "$package"
}

# Restore all backup files
restore() {
    log "Restoring backup files..."
    
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
        validate_package "$package"
        stow_op "" "$package"
        ;;
    remove)
        validate_package "$package"
        stow_op "-D" "$package"
        ;;
    backup)
        validate_package "$package"
        backup "$package"
        ;;
    restore)
        restore
        ;;
    help|--help|-h|*)
        help
        ;;
esac