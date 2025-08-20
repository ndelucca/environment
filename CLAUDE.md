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
```bash
# Install basic applications (requires root)
sudo ./installers/su/basic-apps/install.sh

# Install Sway window manager and related tools (requires root)
sudo ./installers/su/sway/install.sh

# Configure localization (Spanish Latin America locale and Buenos Aires timezone) (requires root)
sudo ./installers/su/localization/install.sh

# Install development environment (Go, Rust, dev directories) (user-level)
./installers/user/development/install.sh

# Install Node Version Manager (user-level)
./installers/user/nvm/install.sh
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
Two-tier installation approach:
- `installers/su/`: System-level installers requiring root privileges
- `installers/user/`: User-level installers for non-privileged software

The Sway installer can either install from distribution packages (default) or build from source (commented out functions available).

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
