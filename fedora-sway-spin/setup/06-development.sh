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

# Print "<label>: <version>" if <bin> exists, else "<label>: NOT INSTALLED".
# Remaining args are the version command to run (its first output line is shown).
check_cmd() {
    local bin="$1" label="$2"; shift 2
    if command -v "${bin}" &>/dev/null; then
        echo "${label}: $("$@" 2>&1 | head -n1)"
    else
        echo "${label}: NOT INSTALLED"
    fi
}

verify_installations() {
    log_info "Verifying installations..."

    echo ""
    echo "=== Installed Versions ==="
    check_cmd go      Go      go version
    check_cmd node    Node.js node --version
    check_cmd npm     npm     npm --version
    check_cmd python3 Python  python3 --version
    check_cmd uv      uv      uv --version

    echo ""
    echo "=== Development Tools ==="
    check_cmd gcc  gcc     gcc --version
    check_cmd make make    make --version
    check_cmd git  git     git --version
    check_cmd jq   jq      jq --version
    check_cmd rg   ripgrep rg --version
    check_cmd fd   fd      fd --version

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
}

main
