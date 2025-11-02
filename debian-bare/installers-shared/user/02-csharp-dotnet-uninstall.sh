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

# Uninstall .NET global tools
uninstall_dotnet_tools() {
    log_info "Uninstalling .NET global tools..."

    if ! command -v dotnet &> /dev/null; then
        log_info ".NET SDK is not installed, skipping tool uninstallation"
        return 0
    fi

    local tools=(
        "dotnet-ef"
        "dotnet-format"
        "dotnet-outdated-tool"
    )

    for tool in "${tools[@]}"; do
        log_info "Uninstalling $tool..."
        if dotnet tool uninstall --global "$tool" 2>/dev/null; then
            log_success "$tool uninstalled successfully"
        else
            log_info "$tool was not installed or already removed"
        fi
    done

    log_success ".NET global tools uninstallation complete"
}

# Remove .NET SDK
remove_dotnet_sdk() {
    log_info "Removing .NET SDK..."

    # Check if dotnet is installed via apt packages
    if dpkg -l | grep -q dotnet-sdk; then
        log_info "Found .NET SDK installed via apt packages..."
        # Remove .NET SDK packages
        log_info "Removing .NET SDK packages..."
        sudo apt remove -y dotnet-sdk-8.0 dotnet-sdk-* || log_warning "Could not remove dotnet-sdk packages"
        sudo apt autoremove -y
    else
        log_info ".NET SDK is not installed via apt packages"
    fi

    # Remove Microsoft package repository configuration
    if [[ -f /etc/apt/sources.list.d/microsoft-prod.list ]]; then
        log_info "Removing Microsoft package repository configuration..."
        sudo rm -f /etc/apt/sources.list.d/microsoft-prod.list
        sudo rm -f /etc/apt/trusted.gpg.d/microsoft.gpg
        log_success "Microsoft repository configuration removed"
    fi

    # Remove packages-microsoft-prod package if installed
    if dpkg -l | grep -q packages-microsoft-prod; then
        log_info "Removing packages-microsoft-prod package..."
        sudo apt remove -y packages-microsoft-prod || log_warning "Could not remove packages-microsoft-prod"
    fi

    # Update apt cache if we modified apt sources
    if [[ -f /etc/apt/sources.list.d/microsoft-prod.list ]] || dpkg -l | grep -q packages-microsoft-prod; then
        sudo apt update
    fi

    log_success ".NET SDK removal complete"
}

# Remove Mono
remove_mono() {
    log_info "Removing Mono..."

    if command -v mono &> /dev/null; then
        log_info "Removing Mono packages..."
        sudo apt remove -y mono-complete || log_warning "Could not remove mono-complete"
        sudo apt autoremove -y
        log_success "Mono removed successfully"
    else
        log_info "Mono is not installed"
    fi
}

# Clean up .NET directories and files
cleanup_dotnet_directories() {
    log_info "Cleaning up .NET directories and files..."

    # Remove .dotnet directory (contains tools and cache)
    if [[ -d "$HOME/.dotnet" ]]; then
        log_warning "Removing $HOME/.dotnet directory..."
        rm -rf "$HOME/.dotnet"
        log_success "$HOME/.dotnet removed"
    fi

    # Remove .nuget directory (NuGet cache)
    if [[ -d "$HOME/.nuget" ]]; then
        log_warning "Removing $HOME/.nuget directory (NuGet cache)..."
        rm -rf "$HOME/.nuget"
        log_success "$HOME/.nuget removed"
    fi

    # Remove .templateengine directory (dotnet templates cache)
    if [[ -d "$HOME/.templateengine" ]]; then
        log_warning "Removing $HOME/.templateengine directory..."
        rm -rf "$HOME/.templateengine"
        log_success "$HOME/.templateengine removed"
    fi

    log_success "Cleanup complete"
}

# Remove C# development directory (with confirmation)
remove_csharp_directory() {
    log_info "Checking C# development directory..."

    local csharp_dir="$HOME/dev/csharp"

    if [[ -d "$csharp_dir" ]]; then
        # Check if directory is empty
        if [[ -z "$(ls -A "$csharp_dir")" ]]; then
            log_info "Removing empty C# directory: $csharp_dir"
            rmdir "$csharp_dir"
            log_success "C# directory removed"
        else
            log_warning "C# directory contains files: $csharp_dir"
            log_warning "Please remove it manually if you want to delete it"
            ls -la "$csharp_dir"
        fi
    else
        log_info "C# directory does not exist"
    fi
}

# Verify uninstallation
verify_uninstallation() {
    log_info "Verifying uninstallation..."

    if command -v dotnet &> /dev/null; then
        log_warning ".NET SDK is still available in PATH"
        dotnet --version
    else
        log_success ".NET SDK has been removed"
    fi

    if command -v mono &> /dev/null; then
        log_warning "Mono is still available in PATH"
        mono --version | head -n 1
    else
        log_success "Mono has been removed"
    fi

    if [[ -d "$HOME/.dotnet" ]]; then
        log_warning "$HOME/.dotnet directory still exists"
    else
        log_success "$HOME/.dotnet directory has been removed"
    fi

    if [[ -f /etc/apt/sources.list.d/microsoft-prod.list ]]; then
        log_warning "Microsoft repository configuration still exists"
    else
        log_success "Microsoft repository configuration has been removed"
    fi

    log_success "Uninstallation verification complete"
}

# Main uninstallation function
main() {
    log_warning "=========================================="
    log_warning "C# and .NET Development Environment Uninstaller"
    log_warning "=========================================="
    log_warning "This will remove:"
    log_warning "  - .NET SDK and all related packages"
    log_warning "  - Mono runtime"
    log_warning "  - .NET global tools"
    log_warning "  - Microsoft package repository"
    log_warning "  - .NET cache and configuration directories"
    log_warning "=========================================="
    echo

    read -p "Are you sure you want to proceed? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        log_info "Uninstallation cancelled"
        exit 0
    fi

    log_info "Starting C# and .NET development environment uninstallation..."

    uninstall_dotnet_tools
    remove_dotnet_sdk
    remove_mono
    cleanup_dotnet_directories
    remove_csharp_directory
    verify_uninstallation

    log_success "C# and .NET development environment uninstallation completed successfully!"
    log_info "Your system has been restored to its previous state."
}

# Run main function
main "$@"
