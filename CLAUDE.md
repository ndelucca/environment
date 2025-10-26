# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About Us

- We are colleagues. You are Claude and you can call me Naza.
- We pair program and debate solutions.
- Say things directly, do not worry about my feelings. Do NOT be sycophant.
- When I ask you something, answer me in the language I asked the question. It will always be English or Spanish.

## Repository Overview

This is a personal Linux system and environment configuration repository based on a bare Debian installation.
The repository is organized into two separate configurations:
- **x11/**: X11-based environment with i3 window manager
- **wayland/**: Wayland-based environment with Sway compositor

Each configuration is completely independent with its own installers, dotfiles, and work files.
The system uses GNU Stow for configuration management and a structured installation approach.
When you are instructed to change the system, it means changing these tools that actually setup the system.

## Key Commands

### Configuration Management

To deploy the systems configuration dotfiles we use the stow-files directory and the manage.sh script.

```bash
# For Wayland/Sway:
# Install user configuration files (creates symlinks to $HOME)
cd wayland/stow-files && ./manage.sh install user
# Install system configuration files (creates symlinks to /, requires sudo)
cd wayland/stow-files && ./manage.sh install system

# For X11/i3:
# Install user configuration files (creates symlinks to $HOME)
cd x11/stow-files && ./manage.sh install user
# Install system configuration files (creates symlinks to /, requires sudo)
cd x11/stow-files && ./manage.sh install system
```

### Installation Scripts

To install system software, run the installer scripts directly from their respective directories.
Common scripts are shared between environments via symlinks to `installers-shared/`.

```bash
# For Wayland/Sway:
# Run system installers (in order: 00-main.sh, then 01-05)
cd wayland/installers/system && ./00-main.sh && ./01-localization.sh && ./02-fonts.sh && ./03-browser.sh && ./04-nvim.sh && ./05-docker.sh

# For X11/i3:
# Run system installers (in order: 00-main.sh, then 01-05)
cd x11/installers/system && ./00-main.sh && ./01-localization.sh && ./02-fonts.sh && ./03-browser.sh && ./04-nvim.sh && ./05-docker.sh

# Run user installers (same for both environments)
cd {wayland,x11}/installers/user && ./00-nvim-config.sh && ./01-development.sh

# Run webserver installers (optional, same for both environments)
cd {wayland,x11}/installers/webserver && ./00-nginx.sh
```

## Architecture

### Top-Level Structure
The repository is divided into two completely independent configurations with shared common installers:

- **installers-shared/**: Common installation scripts used by both environments (via symlinks)
  - **system/**: Locale (01), fonts (02), browser (03), nvim (04), docker (05)
  - **user/**: Neovim config (00), development tools (01)
  - **webserver/**: Nginx configuration (00)

- **x11/**: Complete X11-based environment setup
  - Window Manager: i3
  - Terminal: rxvt-unicode
  - Compositor: picom
  - Launcher: rofi
  - Screenshots: flameshot

- **wayland/**: Complete Wayland-based environment setup
  - Compositor: Sway
  - Terminal: foot
  - Panel: waybar
  - Launcher: wofi
  - Screenshots: grim + slurp

Each configuration directory (x11/, wayland/) contains:
- **installers/**: Installation scripts (00-main.sh is WM-specific, others are symlinks to installers-shared/)
- **stow-files/**: Dotfiles and configuration files
- **work-files/**: Work-related files (VPN configs, etc.)

### Configuration Management System
The dotfiles management uses a two-tier GNU Stow-based file system (within each x11/wayland directory):

- **stow-files/user/**: User-level configurations targeting `$HOME`
  - Bash aliases and prompt customization with Git integration
  - Development environment setup (GOPATH, tmux integration)
  - Work-specific aliases and functions
  - Window manager/compositor specific configs

- **stow-files/system/**: System-level configurations targeting `/` (root filesystem)
  - Greetd display manager configuration
  - Systemd user service definitions
  - System wallpapers and assets

- **manage.sh**: Unified configuration management script that automatically handles permissions based on package type and includes comprehensive backup functionality

### Installation System Architecture
The installation system uses a shared structure with symlinks to avoid duplication:

- **installers-shared/**: Canonical source for common installation scripts
  - All scripts except 00-main.sh are identical between environments
  - Single source of truth for locale, fonts, browser, nvim, docker, development tools, and webserver configs

- **{x11,wayland}/installers/system/**: System-level installers requiring root privileges
  - **00-main.sh**: Environment-specific (actual file, not symlinked)
    - X11: xorg, xinit, i3, rofi, picom, etc.
    - Wayland: wayland-utils, sway, waybar, wofi, foot, etc.
  - **01-05-*.sh**: Common installers (symlinks to installers-shared/system/)
  - Uses numbered prefixes (00-, 01-, etc.) to ensure proper installation order

- **{x11,wayland}/installers/user/**: User-level installers (symlinks to installers-shared/user/)
  - Development tools and configurations

- **{x11,wayland}/installers/webserver/**: Webserver installers (symlinks to installers-shared/webserver/)
  - Nginx and related configurations

### Key Design Patterns
- **Complete Separation**: X11 and Wayland environments are completely independent (except shared installers)
- **Shared Common Scripts**: installers-shared/ eliminates duplication via symlinks
  - Only 00-main.sh differs between environments (WM-specific packages)
  - All other installers are identical and symlinked from installers-shared/
- **Idempotent Operations**: All scripts can be safely re-run without side effects
- **Permission Handling**: The manage.sh script automatically applies sudo for system packages
- **Directory Structure Preservation**: Stow creates only file symlinks, never directory symlinks
- **Backup Safety**: Comprehensive backup system prevents data loss during configuration changes
- **Systemd Integration**: Automatic daemon reload when system configurations are modified

## Theme Color System

Both environments use a consistent green accent color across all components:

- **Primary Accent**: `#4a9d4a` (RGB: 74, 157, 74)
- **Secondary Accent**: `#6cb66c` (RGB: 108, 182, 108)

### Theme Components (Wayland):
- **Bash PS1**: `wayland/stow-files/user/bash_aliases.d/02-ps1.sh` - Terminal prompt colors
- **Sway WM**: `wayland/stow-files/user/.config/sway/config` - Window borders and focused elements
- **Waybar**: `wayland/stow-files/user/.config/waybar/style.css` - Status bar highlights
- **Foot Terminal**: `wayland/stow-files/user/.config/foot/foot.ini` - Terminal color palette
- **Wofi Launcher**: `wayland/stow-files/user/.config/wofi/style.css` - Application launcher selection
- **SwayNC**: `wayland/stow-files/user/.config/swaync/style.css` - Notification styling
- **GTK Applications**: `wayland/stow-files/user/.config/gtk-3.0/gtk.css` and `wayland/stow-files/user/.config/gtk-4.0/gtk.css` - Custom accent colors for GTK apps

### Theme Components (X11):
- **Bash PS1**: `x11/stow-files/user/bash_aliases.d/02-ps1.sh` - Terminal prompt colors
- **i3 WM**: `x11/stow-files/user/.config/i3/config` - Window borders and focused elements
- **i3status**: `x11/stow-files/user/.config/i3status/config` - Status bar highlights
- **URxvt Terminal**: `x11/stow-files/user/.Xresources` - Terminal color palette
- **Rofi Launcher**: `x11/stow-files/user/.config/rofi/config.rasi` - Application launcher selection
- **GTK Applications**: `x11/stow-files/user/.config/gtk-3.0/gtk.css` and `x11/stow-files/user/.config/gtk-4.0/gtk.css` - Custom accent colors for GTK apps

### Changing Theme Accent:
To change the accent color system-wide in either environment:
1. Update `T_MAIN_COLOR` and `T_SECONDARY_COLOR` in the appropriate `bash_aliases.d/02-ps1.sh`
2. Update corresponding colors in all theme component files for the chosen environment
3. Update `@define-color accent_color` and related colors in both GTK CSS files
4. Use RGB values for terminal (format: `38;2;R;G;B`) and hex for CSS files

## Work Files

Each environment configuration (x11/ and wayland/) contains a work-files directory with work-related files:

1. **vpn.7z**: .ovpn file and credentials directory for OpenVPN connections. Zipped with encryption
2. **extract-vpn.sh**: Script to unzip the VPN files. Prompts for the password when run.

Both x11/work-files and wayland/work-files contain the same VPN configuration files.

## Important Notes

- All operations automatically handle permissions - user packages target $HOME, system packages target / with sudo
- The Wayland environment uses sway-session.target for systemd user services
- The X11 environment uses i3-session.target for systemd user services
- Each environment is completely independent - you can switch between them by installing the appropriate configuration
