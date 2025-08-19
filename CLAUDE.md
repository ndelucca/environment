# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is my personal Linux system and environment configuration.
It is based on a bare Debian installation with Sway as desktop environment using Wayland.

- **dotfiles/**: User configuration files managed with GNU Stow
- **installers/**: System and user-level installation scripts
- **systemfiles/**: System-level configuration files also managed with GNU Stow but used with sudo privileges.

## Key Commands

### Dotfiles Management
```bash
# Install all dotfiles (creates symlinks)
cd dotfiles && ./manage.sh install

# Remove dotfiles symlinks  
cd dotfiles && ./manage.sh remove

# Backup existing conflicting files
cd dotfiles && ./manage.sh backup

# Restore backup files
cd dotfiles && ./manage.sh restore

# Check prerequisites (stow and age)
cd dotfiles && ./manage.sh check

# List available modules
cd dotfiles && ./manage.sh list
```

### System Files Management
```bash
# Install system-level configurations (requires root)
cd systemfiles && sudo ./manage.sh install

# Remove system-level configurations
cd systemfiles && sudo ./manage.sh remove

# Backup existing conflicting files (requires root)
cd systemfiles && sudo ./manage.sh backup

# Restore backup files (requires root)
cd systemfiles && sudo ./manage.sh restore

# Check prerequisites (requires root)
cd systemfiles && sudo ./manage.sh check

# List available modules
cd systemfiles && sudo ./manage.sh list
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

### Dotfiles Structure
The dotfiles are modularized and use GNU Stow for symlink management via bash scripts:
- `bash-setup/`: Bash aliases, PS1 customization, and development environment setup
- `config-sway/`: Sway window manager configuration
- `config-tmux/`: Tmux terminal multiplexer configuration  
- `config-git/`: Git configuration
- `config-foot/`: Foot terminal emulator configuration
- `cred-ssh/`: SSH credentials (encrypted with age)
- `webapps-bin/`: Web application binaries
- `manage.sh`: Idempotent bash script for dotfiles management

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

- The systemfiles management script targets root filesystem (`TARGET_DIR := /`) and requires root privileges
- The dotfiles management script targets user home directory (`TARGET_DIR := $(HOME)`)
- Both scripts are idempotent and include comprehensive backup functionality to prevent data loss
- Scripts use colored output for better visibility and proper error handling
- Systemfiles script automatically reloads systemd daemon when needed
- All operations can be safely re-run without side effects
- Encrypted SSH credentials use the `age` encryption tool
