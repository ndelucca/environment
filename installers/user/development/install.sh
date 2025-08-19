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

# Create development directories
create_dev_directories() {
    log_info "Creating development directories..."
    
    local dev_dir="$HOME/dev"
    local directories=("go" "rust" "node")
    
    mkdir -p "$dev_dir"
    
    for dir in "${directories[@]}"; do
        local full_path="$dev_dir/$dir"
        if [[ ! -d "$full_path" ]]; then
            mkdir -p "$full_path"
            log_success "Created directory: $full_path"
        else
            log_info "Directory already exists: $full_path"
        fi
    done
}

# Install Go
install_go() {
    log_info "Installing Go programming language..."
    
    # Check if Go is already installed
    if command -v go &> /dev/null; then
        local current_version
        current_version=$(go version | awk '{print $3}' | sed 's/go//')
        log_info "Go is already installed (version: $current_version)"
        return 0
    fi
    
    # Get latest Go version
    log_info "Fetching latest Go version..."
    local go_version
    go_version=$(curl -s https://go.dev/VERSION?m=text | head -1)
    
    if [[ -z "$go_version" ]]; then
        log_error "Failed to fetch Go version"
        return 1
    fi
    
    log_info "Installing Go $go_version..."
    
    # Download and install Go
    local go_archive="${go_version}.linux-amd64.tar.gz"
    local download_url="https://go.dev/dl/$go_archive"
    local temp_dir
    temp_dir=$(mktemp -d)
    
    cd "$temp_dir"
    
    if curl -L -o "$go_archive" "$download_url"; then
        # Remove existing Go installation if any
        if [[ -d "$HOME/.local/go" ]]; then
            rm -rf "$HOME/.local/go"
        fi
        
        # Create local installation directory
        mkdir -p "$HOME/.local"
        
        # Extract Go
        tar -xzf "$go_archive" -C "$HOME/.local"
        
        log_success "Go $go_version installed successfully to $HOME/.local/go"
    else
        log_error "Failed to download Go"
        return 1
    fi
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Install Rust
install_rust() {
    log_info "Installing Rust programming language..."
    
    # Check if Rust is already installed
    if command -v rustc &> /dev/null; then
        local current_version
        current_version=$(rustc --version | awk '{print $2}')
        log_info "Rust is already installed (version: $current_version)"
        return 0
    fi
    
    # Install Rust using rustup
    log_info "Installing Rust via rustup..."
    
    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path; then
        log_success "Rust installed successfully"
        
        # Source cargo environment
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env"
        
        # Install common Rust tools
        log_info "Installing common Rust development tools..."
        cargo install cargo-watch cargo-edit cargo-outdated
        
        log_success "Rust development tools installed"
    else
        log_error "Failed to install Rust"
        return 1
    fi
}

# Install additional development tools
install_dev_tools() {
    log_info "Installing additional development tools..."
    
    # Install build essentials if not already installed
    if command -v apt &> /dev/null; then
        log_info "Installing build essentials..."
        sudo apt update
        sudo apt install -y build-essential curl wget git
    fi
    
    # Install common development utilities
    local tools=("jq" "tree" "htop" "ripgrep" "fd-find")
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_info "Installing $tool..."
            sudo apt install -y "$tool"
        else
            log_info "$tool is already installed"
        fi
    done
}

# Verify installations
verify_installations() {
    log_info "Verifying installations..."
    
    echo "Development directories:"
    ls -la "$HOME/dev/"
    echo
    
    if command -v go &> /dev/null; then
        echo "Go version:"
        go version
        echo "GOPATH: $HOME/dev/go"
        echo
    fi
    
    if command -v rustc &> /dev/null; then
        echo "Rust version:"
        rustc --version
        echo "Cargo version:"
        cargo --version
        echo
    fi
    
    log_success "Installation verification complete"
}

# Main installation function
main() {
    log_info "Starting development environment setup..."
    
    create_dev_directories
    install_dev_tools
    install_go
    install_rust
    verify_installations
    
    log_success "Development environment setup completed successfully!"
    log_warning "Please restart your shell or run 'source ~/.bashrc' to use the new environment variables."
}

# Run main function
main "$@"