#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly STOW_DIR="${SCRIPT_DIR}"
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
    local dependencies=("stow")
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

# Get available packages
get_packages() {
    local packages=()
    
    if [[ -d "${STOW_DIR}/user" ]]; then
        packages+=("user")
    fi
    
    if [[ -d "${STOW_DIR}/system" ]]; then
        packages+=("system")
    fi
    
    printf '%s\n' "${packages[@]}"
}

# Create directory structure before stow to ensure only files are symlinked
create_directory_structure() {
    local package="$1"
    local target_dir="$2"
    
    log_info "Creating directory structure for package '${package}'"
    
    # Find all directories in the package and create them in target
    while IFS= read -r -d '' dir; do
        local relative_path="${dir#"${STOW_DIR}/${package}"}"
        local target_path="${target_dir}${relative_path}"
        
        if [[ ! -d "$target_path" ]]; then
            log_info "Creating directory: ${target_path}"
            if [[ "$package" == "system" ]]; then
                sudo mkdir -p "$target_path"
            else
                mkdir -p "$target_path"
            fi
        fi
    done < <(find "${STOW_DIR}/${package}" -type d -print0)
}

# Create backups for conflicting files
backup_conflicts() {
    local package="$1"
    local target_dir="$2"
    
    log_info "Creating backups for conflicting files in ${target_dir} for package '${package}'"
    
    local backed_up=0
    
    # Find all files in the package
    while IFS= read -r -d '' file; do
        local relative_path="${file#"${STOW_DIR}/${package}"}"
        local target="${target_dir}${relative_path}"
        
        # Only backup if target exists and is NOT a symlink
        if [[ -e "$target" && ! -L "$target" ]]; then
            local backup_dir
            backup_dir="$(dirname "${target}${BACKUP_SUFFIX}")"
            
            # Ensure backup directory exists
            if [[ "$package" == "system" ]]; then
                sudo mkdir -p "$backup_dir"
                log_warning "Backing up existing file: ${target} -> ${target}${BACKUP_SUFFIX}"
                sudo mv "$target" "${target}${BACKUP_SUFFIX}"
            else
                mkdir -p "$backup_dir"
                log_warning "Backing up existing file: ${target} -> ${target}${BACKUP_SUFFIX}"
                mv "$target" "${target}${BACKUP_SUFFIX}"
            fi
            ((backed_up++))
        fi
    done < <(find "${STOW_DIR}/${package}" -type f -print0)
    
    if [[ $backed_up -gt 0 ]]; then
        log_success "Backup process complete. ${backed_up} files backed up."
    else
        log_info "No conflicting files found. No backups needed."
    fi
}

# Install package using stow
install_package() {
    local package="$1"
    
    if [[ ! -d "${STOW_DIR}/${package}" ]]; then
        log_error "Package '${package}' not found in ${STOW_DIR}"
        return 1
    fi
    
    local target_dir
    local use_sudo=false
    
    case "$package" in
        user)
            target_dir="${HOME}"
            ;;
        system)
            target_dir="/"
            use_sudo=true
            if [[ $EUID -ne 0 ]]; then
                log_info "Package '${package}' requires root privileges. Re-running with sudo..."
                exec sudo -E "$0" install "$package"
            fi
            ;;
        *)
            log_error "Unknown package: $package"
            return 1
            ;;
    esac
    
    log_info "Installing package '${package}' to ${target_dir}"
    
    # Check dependencies
    if ! check_dependencies; then
        return 1
    fi
    
    # Create directory structure first
    create_directory_structure "$package" "$target_dir"
    
    # Install using stow
    log_info "Running: stow -t ${target_dir} -d ${STOW_DIR} ${package}"
    if [[ "$use_sudo" == "true" ]]; then
        if sudo stow -t "${target_dir}" -d "${STOW_DIR}" "${package}"; then
            log_success "Package '${package}' installed successfully"
            
            # Reload systemd if needed
            if systemctl is-system-running &> /dev/null; then
                log_info "Reloading systemd daemon configuration..."
                sudo systemctl daemon-reload
            fi
        else
            log_error "Failed to install package '${package}'"
            log_error "If there are conflicts, run './manage.sh backup ${package}' first"
            return 1
        fi
    else
        if stow -t "${target_dir}" -d "${STOW_DIR}" "${package}"; then
            log_success "Package '${package}' installed successfully"
        else
            log_error "Failed to install package '${package}'"
            log_error "If there are conflicts, run './manage.sh backup ${package}' first"
            return 1
        fi
    fi
}

# Remove package using stow
remove_package() {
    local package="$1"
    
    if [[ ! -d "${STOW_DIR}/${package}" ]]; then
        log_error "Package '${package}' not found in ${STOW_DIR}"
        return 1
    fi
    
    local target_dir
    local use_sudo=false
    
    case "$package" in
        user)
            target_dir="${HOME}"
            ;;
        system)
            target_dir="/"
            use_sudo=true
            if [[ $EUID -ne 0 ]]; then
                log_info "Package '${package}' requires root privileges. Re-running with sudo..."
                exec sudo -E "$0" remove "$package"
            fi
            ;;
        *)
            log_error "Unknown package: $package"
            return 1
            ;;
    esac
    
    log_info "Removing package '${package}' from ${target_dir}"
    
    # Check if stow is available
    if ! command -v stow &> /dev/null; then
        log_error "stow is not installed or not in PATH"
        return 1
    fi
    
    # Remove using stow
    if [[ "$use_sudo" == "true" ]]; then
        if sudo stow -D -t "${target_dir}" -d "${STOW_DIR}" "${package}"; then
            log_success "Package '${package}' removed successfully"
            
            # Reload systemd if needed
            if systemctl is-system-running &> /dev/null; then
                log_info "Reloading systemd daemon configuration..."
                sudo systemctl daemon-reload
            fi
        else
            log_error "Failed to remove package '${package}'"
            return 1
        fi
    else
        if stow -D -t "${target_dir}" -d "${STOW_DIR}" "${package}"; then
            log_success "Package '${package}' removed successfully"
        else
            log_error "Failed to remove package '${package}'"
            return 1
        fi
    fi
}

# Backup conflicts for a specific package
backup_package() {
    local package="$1"
    
    if [[ ! -d "${STOW_DIR}/${package}" ]]; then
        log_error "Package '${package}' not found in ${STOW_DIR}"
        return 1
    fi
    
    local target_dir
    
    case "$package" in
        user)
            target_dir="${HOME}"
            ;;
        system)
            target_dir="/"
            if [[ $EUID -ne 0 ]]; then
                log_info "Package '${package}' requires root privileges. Re-running with sudo..."
                exec sudo -E "$0" backup "$package"
            fi
            ;;
        *)
            log_error "Unknown package: $package"
            return 1
            ;;
    esac
    
    backup_conflicts "$package" "$target_dir"
}

# Restore backup files
restore_backups() {
    log_info "Restoring backup files..."
    
    local restored=0
    local search_paths=("${HOME}" "/")
    
    for search_path in "${search_paths[@]}"; do
        local use_sudo=false
        if [[ "$search_path" == "/" ]]; then
            use_sudo=true
            if [[ $EUID -ne 0 ]]; then
                log_info "System backup restoration requires root privileges. Re-running with sudo..."
                exec sudo -E "$0" restore
            fi
        fi
        
        while IFS= read -r -d '' backup_file; do
            local original_file="${backup_file%"${BACKUP_SUFFIX}"}"
            
            if [[ -f "$backup_file" ]]; then
                log_info "Restoring: ${backup_file} -> ${original_file}"
                if [[ "$use_sudo" == "true" ]]; then
                    sudo mv "$backup_file" "$original_file"
                else
                    mv "$backup_file" "$original_file"
                fi
                ((restored++))
            fi
        done < <(find "$search_path" -name "*${BACKUP_SUFFIX}" -type f -print0 2>/dev/null || true)
    done
    
    if [[ $restored -gt 0 ]]; then
        log_success "Restored ${restored} backup files"
        
        # Reload systemd if needed
        if systemctl is-system-running &> /dev/null; then
            log_info "Reloading systemd daemon configuration..."
            if [[ $EUID -eq 0 ]]; then
                systemctl daemon-reload
            else
                sudo systemctl daemon-reload
            fi
        fi
    else
        log_info "No backup files found to restore"
    fi
}

# Show help
show_help() {
    cat << EOF
Usage: $(basename "$0") [COMMAND] [PACKAGE]

Simplified dotfiles management using GNU Stow.

Commands:
  install <package>   Install package (user|system)
  remove <package>    Remove package (user|system)
  backup <package>    Create backups for conflicting files
  restore             Restore all .bak files to their original names
  list                Show available packages
  help                Show this help message

Packages:
  user                User-level configuration files (target: \$HOME)
  system              System-level configuration files (target: /, requires sudo)

Examples:
  $(basename "$0") install user      # Install user configuration files
  $(basename "$0") install system    # Install system configuration files (requires sudo)
  $(basename "$0") remove user       # Remove user configuration files
  $(basename "$0") backup system     # Backup conflicting system files
  $(basename "$0") restore           # Restore all backup files

Environment:
  STOW_DIR: ${STOW_DIR}

Dependencies: stow

Note: System operations automatically handle sudo requirements.
EOF
}

# List available packages
list_packages() {
    local packages
    readarray -t packages < <(get_packages)
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log_info "No packages found in ${STOW_DIR}"
        return 0
    fi
    
    log_info "Available packages in ${STOW_DIR}:"
    for package in "${packages[@]}"; do
        case "$package" in
            user)
                echo "  - user    (User configuration files, target: \$HOME)"
                ;;
            system)
                echo "  - system  (System configuration files, target: /, requires sudo)"
                ;;
        esac
    done
}

# Main function
main() {
    local command="${1:-help}"
    local package="${2:-}"
    
    case "$command" in
        install)
            if [[ -z "$package" ]]; then
                log_error "Package name required for install command"
                echo
                show_help
                exit 1
            fi
            install_package "$package"
            ;;
        remove)
            if [[ -z "$package" ]]; then
                log_error "Package name required for remove command"
                echo
                show_help
                exit 1
            fi
            remove_package "$package"
            ;;
        backup)
            if [[ -z "$package" ]]; then
                log_error "Package name required for backup command"
                echo
                show_help
                exit 1
            fi
            backup_package "$package"
            ;;
        restore)
            restore_backups
            ;;
        list)
            list_packages
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