# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About Us

- We are colleagues. You are Claude and you can call me Naza.
- We pair program and debate solutions.
- Say things directly, do not worry about my feelings. Do NOT be sycophant.
- When I ask you something, answer me in the language I asked the question. It will always be English or Spanish.

## Repository Overview

This is a personal Linux system and environment configuration repository based on a bare Debian installation with Sway as the desktop environment using Wayland.
The system uses GNU Stow for configuration management and a structured installation approach.
When you are instructed to change the system, it means changing these tools that actually setup the system.

## Key Commands

### Configuration Management

To deploy the systems configuration dotfiles we use the stow-files directory and the manage.sh script.

```bash
# Install user configuration files (creates symlinks to $HOME)
cd stow-files && ./manage.sh install user
# Install system configuration files (creates symlinks to /, requires sudo)
cd stow-files && ./manage.sh install system
```

### Installation Scripts

To install all system software we use the scripts in installers directory and the setup.sh script.
```bash
# Install all system components (excludes optional neovim compilation)
./installers/setup.sh
```

## Architecture

### Configuration Management System
The dotfiles management uses a two-tier GNU Stow-based file system:

- **stow-files/user/**: User-level configurations targeting `$HOME`
  - Bash aliases and prompt customization with Git integration
  - Development environment setup (GOPATH, tmux integration)
  - Work-specific aliases and functions

- **stow-files/system/**: System-level configurations targeting `/` (root filesystem)
  - Greetd display manager configuration
  - Systemd user service definitions
  - System wallpapers and assets

- **manage.sh**: Unified configuration management script that automatically handles permissions based on package type and includes comprehensive backup functionality

### Installation System Architecture
The installation system follows a flat, numbered structure for predictable execution order:

- **installers/setup.sh**: Main entry point that sources all system installers (excluding optional nvim compilation)
- **installers/system/**: System-level installers requiring root privileges
  - Uses numbered prefixes (00-, 01-, etc.) to ensure proper installation order
  - Handles core system packages, Wayland/Sway desktop environment, fonts, and browser
- **installers/user/**: User-level installers for development tools and configurations

### Key Design Patterns
- **Idempotent Operations**: All scripts can be safely re-run without side effects
- **Permission Handling**: The manage.sh script automatically applies sudo for system packages
- **Directory Structure Preservation**: Stow creates only file symlinks, never directory symlinks
- **Backup Safety**: Comprehensive backup system prevents data loss during configuration changes
- **Systemd Integration**: Automatic daemon reload when system configurations are modified

## Theme Color System

The environment uses a consistent green accent color across all components:

- **Primary Accent**: `#4a9d4a` (RGB: 74, 157, 74)
- **Secondary Accent**: `#6cb66c` (RGB: 108, 182, 108)

### Theme Components:
- **Bash PS1**: `stow-files/user/bash_aliases.d/02-ps1.sh` - Terminal prompt colors
- **Sway WM**: `stow-files/user/.config/sway/config` - Window borders and focused elements
- **Waybar**: `stow-files/user/.config/waybar/style.css` - Status bar highlights
- **Foot Terminal**: `stow-files/user/.config/foot/foot.ini` - Terminal color palette
- **Wofi Launcher**: `stow-files/user/.config/wofi/style.css` - Application launcher selection
- **SwayNC**: `stow-files/user/.config/swaync/style.css` - Notification styling
- **GTK Applications**: `stow-files/user/.config/gtk-3.0/gtk.css` and `stow-files/user/.config/gtk-4.0/gtk.css` - Custom accent colors for GTK apps (Blueman, Pavucontrol, etc.)

### Changing Theme Accent:
To change the accent color system-wide:
1. Update `T_MAIN_COLOR` and `T_SECONDARY_COLOR` in `bash_aliases.d/02-ps1.sh`
2. Update corresponding colors in all theme component files listed above
3. Update `@define-color accent_color` and related colors in both GTK CSS files
4. Use RGB values for terminal (format: `38;2;R;G;B`) and hex for CSS files

## Aditional directories

A third top level directory named work-files contains work-related files.

1. vpn.7z: .ovpn file and credentials directory for OpenVPN connections. Zipped with encryption
2. To unzip we can use extract-vpn.sh script. It asks me for the password when I run it.

## Important Notes

- All operations automatically handle permissions - user packages target $HOME, system packages target / with sudo
- Systemd user services are managed through sway-session.target
