#!/usr/bin/env bash

set -euo pipefail

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

# Check if script is running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Configure English US locale
configure_locale() {
    log_info "Configuring English US locale..."
    
    # Install locales package if not already installed
    if ! dpkg -l | grep -q "^ii.*locales "; then
        log_info "Installing locales package..."
        apt update
        apt install -y locales
    fi
    
    # Generate English US locales
    log_info "Generating English US locales..."
    
    # Uncomment English US locales in /etc/locale.gen
    sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    
    # Generate locales
    locale-gen
    
    # Set default locale to English US
    log_info "Setting default locale to en_US.UTF-8..."
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
    
    # Update /etc/default/locale
    cat > /etc/default/locale << EOF
LANG=en_US.UTF-8
LANGUAGE=en_US:en
LC_ALL=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_NUMERIC=en_US.UTF-8
LC_TIME=en_US.UTF-8
LC_COLLATE=en_US.UTF-8
LC_MONETARY=en_US.UTF-8
LC_MESSAGES=en_US.UTF-8
LC_PAPER=en_US.UTF-8
LC_NAME=en_US.UTF-8
LC_ADDRESS=en_US.UTF-8
LC_TELEPHONE=en_US.UTF-8
LC_MEASUREMENT=en_US.UTF-8
LC_IDENTIFICATION=en_US.UTF-8
EOF
    
    log_success "English US locale configured successfully"
}

# Configure timezone for Buenos Aires, Argentina
configure_timezone() {
    log_info "Configuring timezone for Buenos Aires, Argentina..."
    
    # Set timezone using timedatectl (systemd)
    if command -v timedatectl &> /dev/null; then
        log_info "Using timedatectl to set timezone..."
        timedatectl set-timezone America/Argentina/Buenos_Aires
    else
        # Fallback method for systems without systemd
        log_info "Using traditional method to set timezone..."
        ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
        echo "America/Argentina/Buenos_Aires" > /etc/timezone
    fi
    
    # Configure timezone data
    if command -v dpkg-reconfigure &> /dev/null; then
        log_info "Reconfiguring tzdata..."
        echo "America/Argentina/Buenos_Aires" > /etc/timezone
        dpkg-reconfigure -f noninteractive tzdata
    fi
    
    log_success "Timezone configured to Buenos Aires, Argentina"
}

# Verify configuration
verify_configuration() {
    log_info "Verifying localization configuration..."
    
    echo "Current locale settings:"
    locale
    echo
    
    echo "Current timezone:"
    if command -v timedatectl &> /dev/null; then
        timedatectl status | grep "Time zone"
    else
        cat /etc/timezone
    fi
    echo
    
    echo "Current date and time:"
    date
    echo
    
    log_success "Configuration verification complete"
}

# Main installation function
main() {
    log_info "Starting localization configuration for English US and Buenos Aires timezone..."
    
    check_root
    configure_locale
    configure_timezone
    verify_configuration
    
    log_success "Localization configuration completed successfully!"
    log_warning "Please reboot or log out and back in for all changes to take effect."
}

# Run main function
main "$@"