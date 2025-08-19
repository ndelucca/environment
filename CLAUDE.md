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
cd dotfiles && make stow

# Remove dotfiles symlinks  
cd dotfiles && make unstow

# Backup existing conflicting files
cd dotfiles && make backup

# Check prerequisites (stow and age)
cd dotfiles && make check
```

### System Files Management
```bash
# Install system-level configurations (requires root)
cd systemfiles && sudo make stow

# Remove system-level configurations
cd systemfiles && sudo make unstow
```

### Installation Scripts
```bash
# Install basic applications (requires root)
sudo ./installers/su/basic-apps/install.sh

# Install Sway window manager and related tools (requires root)
sudo ./installers/su/sway/install.sh

# Install Node Version Manager (user-level)
./installers/user/nvm/install.sh
```

## Architecture

### Dotfiles Structure
The dotfiles are modularized and use GNU Stow for symlink management:
- `bash-setup/`: Bash aliases, PS1 customization, and development environment setup
- `config-sway/`: Sway window manager configuration
- `config-tmux/`: Tmux terminal multiplexer configuration  
- `config-git/`: Git configuration
- `config-foot/`: Foot terminal emulator configuration
- `cred-ssh/`: SSH credentials (encrypted with age)
- `webapps-bin/`: Web application binaries

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

- The systemfiles Makefile targets root filesystem (`TARGET_DIR := /`) and requires root privileges
- The dotfiles Makefile targets user home directory (`TARGET_DIR := $(HOME)`)
- Both systems include backup functionality to prevent data loss
- Encrypted SSH credentials use the `age` encryption tool
