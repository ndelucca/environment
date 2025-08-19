#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="${SCRIPT_DIR}"
readonly TARGET_DIR="${HOME}"
readonly BACKUP_SUFFIX=".bak"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Check if required tools are available
check_dependencies() {
    local dependencies=("stow" "age")
    local missing=()
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing[*]}"
        log_error "Please install them before continuing."
        return 1
    fi
    
    log_success "All dependencies are available"
    return 0
}

# Get the single module (user-dotfiles)
get_modules() {
    echo "user-dotfiles"
}

# Create backups for conflicting files
backup_conflicts() {
    local modules
    readarray -t modules < <(get_modules)
    
    log_info "Creating backups for conflicting files in ${TARGET_DIR}..."
    
    local backed_up=0
    for module in "${modules[@]}"; do
        log_info "Checking module '${module}' for conflicts..."
        
        # Find all files in the module (up to 5 levels deep)
        while IFS= read -r -d '' file; do
            # Calculate target path by removing module prefix and dotfiles dir
            local relative_path="${file#"${DOTFILES_DIR}/${module}"}"
            local target="${TARGET_DIR}${relative_path}"
            
            # Only backup if target exists and is NOT a symlink (real files/directories only)
            if [[ -e "$target" ]]; then
                if [[ -L "$target" ]]; then
                    log_info "Skipping symlink: ${target} (already managed by stow)"
                else
                    log_warning "Backing up existing file: ${target} -> ${target}${BACKUP_SUFFIX}"
                    mv "$target" "${target}${BACKUP_SUFFIX}"
                    ((backed_up++))
                fi
            fi
        done < <(find "${DOTFILES_DIR}/${module}" -mindepth 1 -maxdepth 5 -type f -print0)
    done
    
    if [[ $backed_up -gt 0 ]]; then
        log_success "Backup process complete. ${backed_up} files backed up."
    else
        log_info "No conflicting files found. No backups needed."
    fi
}

# Install dotfiles using stow
install_dotfiles() {
    log_info "Installing dotfiles with stow..."
    
    # Check dependencies first
    if ! check_dependencies; then
        return 1
    fi
    
    # Get modules to install
    local modules
    readarray -t modules < <(get_modules)
    
    if [[ ${#modules[@]} -eq 0 ]]; then
        log_warning "No modules found in ${DOTFILES_DIR}"
        return 0
    fi
    
    # Install using stow
    log_info "Running: stow -t ${TARGET_DIR} -d ${DOTFILES_DIR} ${modules[*]}"
    if stow -t "${TARGET_DIR}" -d "${DOTFILES_DIR}" "${modules[@]}"; then
        log_success "Dotfiles installed successfully"
        log_info "Installed module: user-dotfiles"
    else
        log_error "Failed to install dotfiles"
        log_error "If there are conflicts, run './manage.sh backup' first or resolve them manually"
        return 1
    fi
}

# Remove dotfiles using stow
remove_dotfiles() {
    log_info "Removing dotfiles with stow..."
    
    # Check if stow is available
    if ! command -v stow &> /dev/null; then
        log_error "stow is not installed or not in PATH"
        return 1
    fi
    
    # Get modules to remove
    local modules
    readarray -t modules < <(get_modules)
    
    if [[ ${#modules[@]} -eq 0 ]]; then
        log_warning "No modules found in ${DOTFILES_DIR}"
        return 0
    fi
    
    # Remove using stow
    if stow -D -t "${TARGET_DIR}" -d "${DOTFILES_DIR}" "${modules[@]}"; then
        log_success "Dotfiles removed successfully"
        log_info "Removed module: user-dotfiles"
    else
        log_error "Failed to remove dotfiles"
        return 1
    fi
}

# Restore backup files
restore_backups() {
    log_info "Restoring backup files..."
    
    local restored=0
    while IFS= read -r -d '' backup_file; do
        local original_file="${backup_file%"${BACKUP_SUFFIX}"}"
        
        if [[ -f "$backup_file" ]]; then
            log_info "Restoring: ${backup_file} -> ${original_file}"
            mv "$backup_file" "$original_file"
            ((restored++))
        fi
    done < <(find "${TARGET_DIR}" -name "*${BACKUP_SUFFIX}" -type f -print0)
    
    if [[ $restored -gt 0 ]]; then
        log_success "Restored ${restored} backup files"
    else
        log_info "No backup files found to restore"
    fi
}

# Show help
show_help() {
    cat << EOF
Usage: $(basename "$0") [COMMAND]

Manage dotfiles using GNU Stow with idempotent operations.

Commands:
  install     Install dotfiles (creates symlinks)
  remove      Remove dotfiles (removes symlinks)
  backup      Create backups for conflicting files only
  restore     Restore all .bak files to their original names
  check       Check if required dependencies are installed
  list        Show available module
  help        Show this help message

Environment:
  DOTFILES_DIR: ${DOTFILES_DIR}
  TARGET_DIR:   ${TARGET_DIR}

Dependencies: stow, age
EOF
}

# List available modules
list_modules() {
    local modules
    readarray -t modules < <(get_modules)
    
    if [[ ${#modules[@]} -eq 0 ]]; then
        log_info "No modules found in ${DOTFILES_DIR}"
        return 0
    fi
    
    log_info "Available module in ${DOTFILES_DIR}:"
    echo "  - user-dotfiles"
}

# Main function
main() {
    local command="${1:-help}"
    
    case "$command" in
        install|stow)
            install_dotfiles
            ;;
        remove|unstow)
            remove_dotfiles
            ;;
        backup)
            check_dependencies && backup_conflicts
            ;;
        restore)
            restore_backups
            ;;
        check)
            check_dependencies
            ;;
        list)
            list_modules
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi