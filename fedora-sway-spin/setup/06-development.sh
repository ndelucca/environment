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
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create development directory structure
create_dev_directories() {
    log_info "Creating development directory structure..."

    # Create main dev directory
    mkdir -p "$HOME/dev"

    # Create language-specific directories
    local dirs=(
        "$HOME/dev/go/src"
        "$HOME/dev/go/bin"
        "$HOME/dev/go/pkg"
        "$HOME/dev/rust"
        "$HOME/dev/node"
        "$HOME/dev/python"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        log_success "Created directory: $dir"
    done
}

# Install Go via dnf (Fedora's official method)
install_go() {
    log_info "Installing Go..."

    if command -v go &> /dev/null; then
        local current_version=$(go version | awk '{print $3}')
        log_warning "Go is already installed: $current_version"
        return 0
    fi

    # Install Go using dnf (Fedora's official recommendation)
    sudo dnf install -y golang

    if command -v go &> /dev/null; then
        log_success "Go installed successfully: $(go version)"
    else
        log_error "Go installation failed"
        return 1
    fi
}

# Install Rust via rustup
install_rust() {
    log_info "Installing Rust..."

    if command -v rustc &> /dev/null; then
        local current_version=$(rustc --version)
        log_warning "Rust is already installed: $current_version"
    else
        # Install rustup (official Rust installer)
        log_info "Downloading and installing rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

        # Source cargo environment
        source "$HOME/.cargo/env"

        log_success "Rust installed successfully: $(rustc --version)"
    fi

    # Install useful cargo tools
    log_info "Installing cargo development tools..."

    # Source cargo env if it exists
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi

    local cargo_tools=(
        "cargo-watch"
        "cargo-edit"
        "cargo-outdated"
    )

    for tool in "${cargo_tools[@]}"; do
        if ! cargo install --list | grep -q "^$tool "; then
            log_info "Installing $tool..."
            cargo install "$tool"
        else
            log_warning "$tool is already installed"
        fi
    done

    log_success "Cargo tools installed"
}

# Install Python development tools
install_python_tools() {
    log_info "Installing Python development tools..."

    # Install pip via dnf
    sudo dnf install -y python3-pip

    # Install uv (fast Python package installer and resolver)
    if ! command -v uv &> /dev/null; then
        log_info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh

        # Source cargo environment to get uv in PATH
        if [ -f "$HOME/.cargo/env" ]; then
            source "$HOME/.cargo/env"
        fi

        log_success "uv installed successfully"
    else
        log_warning "uv is already installed"
    fi
}

# Install NVM and Node.js
install_nvm() {
    log_info "Installing NVM (Node Version Manager)..."

    local NVM_DIR="$HOME/.nvm"

    if [ -d "$NVM_DIR" ]; then
        log_warning "NVM is already installed"
    else
        # Install NVM
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

        log_success "NVM installed successfully"
    fi

    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

    # Install latest LTS version of Node.js
    if command -v nvm &> /dev/null; then
        log_info "Installing latest LTS version of Node.js..."
        nvm install --lts
        nvm use --lts
        log_success "Node.js installed: $(node --version)"
    else
        log_error "NVM installation failed"
        return 1
    fi
}

# Install development tools and utilities
install_dev_tools() {
    log_info "Installing development tools and utilities..."

    # Install C Development Tools group (equivalent to build-essential)
    log_info "Installing c-development group..."
    sudo dnf group install -y c-development

    # Install common development utilities
    log_info "Installing development utilities..."
    sudo dnf install -y \
        curl \
        wget \
        git \
        jq \
        tree \
        htop \
        ripgrep \
        fd-find

    log_success "Development tools installed successfully"
}

# Verify installations
verify_installations() {
    log_info "Verifying installations..."

    echo ""
    echo "=== Installed Versions ==="

    # Go
    if command -v go &> /dev/null; then
        echo "Go: $(go version)"
    else
        echo "Go: NOT INSTALLED"
    fi

    # Rust
    if command -v rustc &> /dev/null; then
        echo "Rust: $(rustc --version)"
        echo "Cargo: $(cargo --version)"
    else
        echo "Rust: NOT INSTALLED"
    fi

    # Python
    if command -v python3 &> /dev/null; then
        echo "Python: $(python3 --version)"
    fi
    if command -v pip3 &> /dev/null; then
        echo "Pip: $(pip3 --version | awk '{print $1, $2}')"
    fi
    if command -v uv &> /dev/null; then
        echo "uv: $(uv --version)"
    fi

    # Node.js
    if command -v node &> /dev/null; then
        echo "Node.js: $(node --version)"
        echo "npm: $(npm --version)"
    else
        echo "Node.js: NOT INSTALLED"
    fi

    # Development tools
    echo ""
    echo "=== Development Tools ==="
    command -v gcc &> /dev/null && echo "gcc: $(gcc --version | head -n1)"
    command -v make &> /dev/null && echo "make: $(make --version | head -n1)"
    command -v git &> /dev/null && echo "git: $(git --version)"
    command -v jq &> /dev/null && echo "jq: $(jq --version)"
    command -v rg &> /dev/null && echo "ripgrep: $(rg --version | head -n1)"
    command -v fd &> /dev/null && echo "fd: $(fd --version)"

    echo ""
}

# Main execution
main() {
    log_info "Starting Fedora development environment setup..."
    echo ""

    create_dev_directories
    install_dev_tools
    install_python_tools
    install_go
    install_rust
    install_nvm
    verify_installations

    echo ""
    log_success "Development environment setup complete!"
    echo ""
    log_info "Note: You may need to restart your shell or source ~/.bashrc for all changes to take effect"
    log_info "Run 'source ~/.bashrc' or start a new terminal session"
}

main
