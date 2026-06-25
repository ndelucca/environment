#!/usr/bin/env bash

set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

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

create_dev_directories() {
    log_info "Creating development directory structure..."

    local dirs=(
        "$HOME/dev/go/src"
        "$HOME/dev/go/bin"
        "$HOME/dev/go/pkg"
        "$HOME/dev/node"
        "$HOME/dev/python"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        log_success "Created directory: $dir"
    done
}

install_build_tools() {
    log_info "Installing c-development group..."
    sudo dnf group install -y c-development
    log_success "Build tools installed"
}

verify_installations() {
    log_info "Verifying installations..."

    echo ""
    echo "=== Installed Versions ==="

    command -v go      &> /dev/null && echo "Go: $(go version)"            || echo "Go: NOT INSTALLED"
    command -v node    &> /dev/null && echo "Node.js: $(node --version)"   || echo "Node.js: NOT INSTALLED"
    command -v npm     &> /dev/null && echo "npm: $(npm --version)"        || echo "npm: NOT INSTALLED"
    command -v python3 &> /dev/null && echo "Python: $(python3 --version)"
    command -v uv      &> /dev/null && echo "uv: $(uv --version)"          || echo "uv: NOT INSTALLED"

    echo ""
    echo "=== Development Tools ==="
    command -v gcc  &> /dev/null && echo "gcc: $(gcc --version | head -n1)"
    command -v make &> /dev/null && echo "make: $(make --version | head -n1)"
    command -v git  &> /dev/null && echo "git: $(git --version)"
    command -v jq   &> /dev/null && echo "jq: $(jq --version)"
    command -v rg   &> /dev/null && echo "ripgrep: $(rg --version | head -n1)"
    command -v fd   &> /dev/null && echo "fd: $(fd --version)"

    echo ""
}

main() {
    log_info "Starting Fedora development environment setup..."
    echo ""

    create_dev_directories
    install_build_tools
    verify_installations

    echo ""
    log_success "Development environment setup complete!"
    echo ""
    log_info "Note: open a new shell (or 'source ~/.bashrc') for PATH changes to take effect."
}

main
