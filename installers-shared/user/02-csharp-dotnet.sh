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

# Create C# development directory
create_csharp_directory() {
    log_info "Creating C# development directory..."

    local dev_dir="$HOME/dev"
    local csharp_dir="$dev_dir/csharp"

    mkdir -p "$dev_dir"

    if [[ ! -d "$csharp_dir" ]]; then
        mkdir -p "$csharp_dir"
        log_success "Created directory: $csharp_dir"
    else
        log_info "Directory already exists: $csharp_dir"
    fi
}

# Install .NET SDK
install_dotnet_sdk() {
    log_info "Installing .NET SDK..."

    # Check if dotnet is already installed
    if command -v dotnet &> /dev/null; then
        local current_version
        current_version=$(dotnet --version)
        log_info ".NET SDK is already installed (version: $current_version)"
        return 0
    fi

    # Install prerequisites
    log_info "Installing prerequisites..."
    sudo apt update
    sudo apt install -y wget apt-transport-https curl libicu-dev bc

    # Get Debian version
    local debian_version
    debian_version=$(lsb_release -rs)

    log_info "Detected Debian version: $debian_version"

    # For Debian 13 (Trixie) and newer, use manual installation as Microsoft packages may not be available yet
    if [[ $(echo "$debian_version >= 13" | bc -l) -eq 1 ]]; then
        log_warning "Debian $debian_version detected. Microsoft packages may not be available yet."
        log_info "Using manual .NET SDK installation method..."

        # Download and install .NET SDK manually
        local dotnet_version="8.0"
        local dotnet_install_dir="$HOME/.dotnet"

        # Download the official install script
        log_info "Downloading .NET install script..."
        wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh
        chmod +x /tmp/dotnet-install.sh

        # Install .NET SDK
        log_info "Installing .NET SDK $dotnet_version..."
        /tmp/dotnet-install.sh --channel $dotnet_version --install-dir "$dotnet_install_dir"

        # Clean up
        rm /tmp/dotnet-install.sh

        # Add to PATH for this session
        export PATH="$dotnet_install_dir:$PATH"
        export DOTNET_ROOT="$dotnet_install_dir"

        if command -v dotnet &> /dev/null; then
            log_success ".NET SDK installed successfully to $dotnet_install_dir"
            local installed_version
            installed_version=$(dotnet --version)
            log_info "Installed version: $installed_version"
            log_warning "Make sure to add $dotnet_install_dir to your PATH in ~/.bashrc"
        else
            log_error "Failed to install .NET SDK"
            return 1
        fi
    else
        # For Debian 12 and older, use Microsoft packages
        log_info "Using Microsoft package repository for Debian $debian_version..."

        # Download Microsoft package repository configuration
        wget https://packages.microsoft.com/config/debian/${debian_version}/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
        sudo dpkg -i /tmp/packages-microsoft-prod.deb
        rm /tmp/packages-microsoft-prod.deb

        # Install .NET SDK
        sudo apt update
        sudo apt install -y dotnet-sdk-8.0

        if command -v dotnet &> /dev/null; then
            log_success ".NET SDK installed successfully"
            local installed_version
            installed_version=$(dotnet --version)
            log_info "Installed version: $installed_version"
        else
            log_error "Failed to install .NET SDK"
            return 1
        fi
    fi
}

# Install common .NET tools
install_dotnet_tools() {
    log_info "Installing common .NET global tools..."

    if ! command -v dotnet &> /dev/null; then
        log_error ".NET SDK is not installed. Please install .NET SDK first."
        return 1
    fi

    # Array of common .NET global tools
    local tools=(
        "dotnet-ef"           # Entity Framework Core tools
        "dotnet-format"       # Code formatter
        "dotnet-outdated-tool" # Check for outdated packages
    )

    for tool in "${tools[@]}"; do
        log_info "Installing $tool..."
        if dotnet tool install --global "$tool" 2>/dev/null; then
            log_success "$tool installed successfully"
        else
            # Tool might already be installed, try to update
            if dotnet tool update --global "$tool" 2>/dev/null; then
                log_success "$tool updated successfully"
            else
                log_warning "Could not install or update $tool (it may already be installed)"
            fi
        fi
    done

    log_success "Common .NET tools installation complete"
}

# Install C# development packages
install_csharp_dev_packages() {
    log_info "Installing C# development packages..."

    # Install Mono (optional, for compatibility with older .NET Framework projects)
    log_info "Installing Mono (for .NET Framework compatibility)..."
    sudo apt update
    sudo apt install -y mono-complete

    log_success "C# development packages installed"
}

# Setup .NET environment
setup_dotnet_environment() {
    log_info "Setting up .NET environment..."

    # Enable .NET CLI telemetry opt-out (privacy)
    export DOTNET_CLI_TELEMETRY_OPTOUT=1

    # Add .NET tools to PATH (they're installed in ~/.dotnet/tools)
    local dotnet_tools_path="$HOME/.dotnet/tools"

    if [[ -d "$dotnet_tools_path" ]]; then
        log_info ".NET tools directory exists at $dotnet_tools_path"
        log_warning "Make sure $dotnet_tools_path is in your PATH"
    fi

    log_success ".NET environment setup complete"
}

# Verify installations
verify_installations() {
    log_info "Verifying installations..."

    echo "C# development directory:"
    ls -la "$HOME/dev/csharp/" 2>/dev/null || echo "Directory not yet populated"
    echo

    if command -v dotnet &> /dev/null; then
        echo ".NET SDK version:"
        dotnet --version
        echo

        echo ".NET SDK info:"
        dotnet --info
        echo

        echo "Installed .NET global tools:"
        dotnet tool list --global
        echo
    else
        log_error ".NET SDK is not available in PATH"
    fi

    if command -v mono &> /dev/null; then
        echo "Mono version:"
        mono --version | head -n 1
        echo
    fi

    log_success "Installation verification complete"
}

# Main installation function
main() {
    log_info "Starting C# and .NET development environment setup..."

    create_csharp_directory
    install_dotnet_sdk
    install_dotnet_tools
    install_csharp_dev_packages
    setup_dotnet_environment
    verify_installations

    log_success "C# and .NET development environment setup completed successfully!"
    log_warning "Please restart your shell or run 'source ~/.bashrc' to ensure all tools are in your PATH."
    log_info "Note: .NET global tools are installed in ~/.dotnet/tools"
}

# Run main function
main "$@"
