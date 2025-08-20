# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is my personal Linux system and environment configuration.
It is based on a bare Debian installation with Sway as desktop environment using Wayland.

- **stow-files/**: Unified configuration files managed with GNU Stow
  - **user/**: User configuration files (target: $HOME)
  - **system/**: System-level configuration files (target: /, requires sudo)
- **installers/**: System and user-level installation scripts

## Key Commands

### Configuration Management
```bash
# Install user configuration files (creates symlinks to $HOME)
cd stow-files && ./manage.sh install user

# Install system configuration files (creates symlinks to /, requires sudo)
cd stow-files && ./manage.sh install system

# Remove user configuration symlinks
cd stow-files && ./manage.sh remove user

# Remove system configuration symlinks (requires sudo)
cd stow-files && ./manage.sh remove system

# Backup existing conflicting files before installation
cd stow-files && ./manage.sh backup user
cd stow-files && ./manage.sh backup system

# Restore all backup files (handles both user and system)
cd stow-files && ./manage.sh restore

# List available packages
cd stow-files && ./manage.sh list
```

### Installation Scripts

#### Managed Installation (Recommended)
```bash
# Install everything in correct order (excludes neovim compilation)
./installers/manage-installers.sh all

# Install only system components
./installers/manage-installers.sh system

# Install only user components  
./installers/manage-installers.sh user

# Install optional components (neovim compilation)
./installers/manage-installers.sh optional

# List all available installers
./installers/manage-installers.sh list
```

#### Individual Installers
```bash
# System-level installers (sudo included internally)
./installers/system/localization-install.sh    # Run first (locale setup)
./installers/system/basic-apps-install.sh      # Core applications + GTK apps
./installers/system/wayland-install.sh         # Wayland components
./installers/system/fonts-install.sh           # Nerd Fonts
./installers/system/foot-install.sh            # Terminal emulator
./installers/system/sway-install.sh            # Sway window manager
./installers/system/google-chrome-install.sh   # Web browser
./installers/system/nvim-install.sh            # Neovim (compilation, optional)

# User-level installers
./installers/user/development-install.sh       # Development tools (Go, Rust, Python)
./installers/user/nvm-install.sh              # Node Version Manager
./installers/user/nvim-config.sh              # Neovim configuration
```

## Architecture

### Configuration Structure
The configuration files are unified into a single directory structure using GNU Stow for symlink management:
- `stow-files/user/`: User configuration files including:
  - Bash aliases, PS1 customization, and development environment setup
  - Sway window manager configuration
  - Tmux terminal multiplexer configuration
  - Git configuration
  - Foot terminal emulator configuration
  - SSH credentials (encrypted with age)
  - Web application binaries
- `stow-files/system/`: System configuration files including:
  - Greetd display manager configuration
  - Systemd user service definitions
  - System wallpapers and assets
- `manage.sh`: Unified, simplified bash script for configuration management

### Installation System
Two-tier installation approach with simplified flat structure:
- `installers/system/`: System-level installers requiring root privileges (flat structure with `<app>-install.sh` naming)
- `installers/user/`: User-level installers for non-privileged software (flat structure with `<app>-install.sh` naming)

All installation scripts follow a consistent naming pattern: `<application>-install.sh` for easy discovery and execution.

### System Integration
- Uses systemd for service management (sway-session.target)
- Integrates with greetd display manager
- Supports PipeWire for audio and Bluez for Bluetooth
- Background wallpaper management through swaybg

## Development Environment

The bash setup includes:
- Git prompt integration with branch status
- Development aliases and utilities
- GOPATH configuration for Go development
- Tmux integration
- Work-specific aliases and functions

## Important Notes

- The unified management script automatically handles permissions based on package type:
  - `user` package targets user home directory (`$HOME`)
  - `system` package targets root filesystem (`/`) and automatically uses sudo when needed
- The script is idempotent and includes comprehensive backup functionality to prevent data loss
- Creates directory structure before stow execution to ensure only files are symlinked, never directories
- Uses colored output for better visibility and proper error handling
- Automatically reloads systemd daemon when system files are modified
- All operations can be safely re-run without side effects
- Encrypted SSH credentials use the `age` encryption tool
