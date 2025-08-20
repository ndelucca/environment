#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[INSTALLER]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Installation order (dependencies first)
SYSTEM_INSTALLERS=(
    "localization-install.sh"
    "basic-apps-install.sh"
    "wayland-install.sh"
    "fonts-install.sh"
    "foot-install.sh"
    "sway-install.sh"
    "google-chrome-install.sh"
)

USER_INSTALLERS=(
    "development-install.sh"
    "nvm-install.sh"
    "nvim-config.sh"
)

# Excluded by default (compilation takes time)
OPTIONAL_INSTALLERS=(
    "nvim-install.sh"
)

run_installer() {
    local installer="$1"
    local type="$2"
    
    local full_path="$SCRIPT_DIR/$type/$installer"
    
    if [[ ! -f "$full_path" ]]; then
        error "Installer not found: $full_path"
        return 1
    fi
    
    log "Running $installer..."
    if "$full_path"; then
        success "$installer completed successfully"
    else
        error "$installer failed"
        return 1
    fi
}

install_system() {
    log "Installing system-level components..."
    for installer in "${SYSTEM_INSTALLERS[@]}"; do
        run_installer "$installer" "system"
    done
}

install_user() {
    log "Installing user-level components..."
    for installer in "${USER_INSTALLERS[@]}"; do
        run_installer "$installer" "user"
    done
}

install_optional() {
    log "Installing optional components..."
    for installer in "${OPTIONAL_INSTALLERS[@]}"; do
        run_installer "$installer" "system"
    done
}

show_help() {
    cat << EOF
Usage: $(basename "$0") [COMMAND]

Manage and execute installation scripts in the correct order.

Commands:
  all        Install all components (system + user, excludes optional)
  system     Install only system-level components
  user       Install only user-level components  
  optional   Install optional components (neovim compilation)
  list       Show all available installers
  help       Show this help message

Examples:
  $(basename "$0") all        # Install everything except neovim compilation
  $(basename "$0") system     # Install only system components
  $(basename "$0") optional   # Compile and install neovim

Note: System installers require sudo permissions and will prompt as needed.
EOF
}

list_installers() {
    echo "System installers (in execution order):"
    for installer in "${SYSTEM_INSTALLERS[@]}"; do
        echo "  - $installer"
    done
    
    echo ""
    echo "User installers (in execution order):"
    for installer in "${USER_INSTALLERS[@]}"; do
        echo "  - $installer"
    done
    
    echo ""
    echo "Optional installers (excluded from 'all'):"
    for installer in "${OPTIONAL_INSTALLERS[@]}"; do
        echo "  - $installer"
    done
}

main() {
    local command="${1:-help}"
    
    case "$command" in
        all)
            log "Installing all components (system + user)..."
            install_system
            install_user
            success "All installations completed!"
            warning "Don't forget to install stow configurations: cd stow-files && ./manage.sh install user && ./manage.sh install system"
            ;;
        system)
            install_system
            ;;
        user)
            install_user
            ;;
        optional)
            install_optional
            ;;
        list)
            list_installers
            ;;
        help|--help|-h|*)
            show_help
            ;;
    esac
}

main "$@"