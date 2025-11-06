# README.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this directory.

## About OrcaSlicer Configuration

This is an OrcaSlicer configuration directory containing user settings, presets, and system configurations for 3D printing. OrcaSlicer is a 3D printing slicer application that converts 3D models into instructions (G-code) for 3D printers.

It is symlinked to the OrcaSlicer configuration directory via stow.

Current OrcaSlicer settings are located in /home/ndelucca/.config/OrcaSlicer

## Directory Structure

- **OrcaSlicer.conf**: Main configuration file containing application settings, printer presets, filament configurations, and user preferences in JSON format
- **user/**: User-created custom configurations
  - **default/machine/**: Custom printer profiles (e.g., Klipper configurations)
  - **default/filament/**: Custom filament settings
  - **default/process/**: Custom print process settings
- **printers/**: Network printer configurations and G-code scripts

## Configuration Management

### Printer Configurations
- System printer profiles are defined in `system/Creality/machine/*.json`
- User custom printers are stored in `user/default/machine/`
- Each printer has associated process settings for different quality levels (Draft, Standard, Fine)

### Filament Settings
- Base filament types defined in `system/OrcaFilamentLibrary/filament/base/`
- Brand-specific filament profiles in respective vendor directories
- Custom user filaments stored in `user/default/filament/`

### Process Settings
- Print quality presets (layer height, speed, temperature) in `system/*/process/`
- Custom process settings in `user/default/process/`

## Key Configuration Concepts

### Preset Relationships
OrcaSlicer uses a three-way preset system:
1. **Machine**: Physical printer characteristics (bed size, nozzle diameter, capabilities)
2. **Filament**: Material properties (temperature, flow rate, retraction settings)
3. **Process**: Print quality settings (layer height, speed, infill)

### Configuration Inheritance
- System configurations provide base templates
- User configurations override or extend system settings
- The main config file tracks active preset combinations

## Common Operations

### Adding Custom Printer
1. Create machine JSON file in `user/default/machine/`
2. Add corresponding process settings if needed
3. Update main config to reference new machine

### Modifying Print Settings
- Edit existing process JSON files for permanent changes
- Temporary changes are stored in the main config's `orca_presets` array

### Network Printer Management
- Printer connection settings stored in `printers/*.json`
- Associated G-code scripts for loading/unloading in `printers/`

## File Format Notes
- All configuration files use JSON format
- Machine definitions include physical constraints and capabilities
- Process files contain detailed print parameter hierarchies
- Filament files specify material-specific printing characteristics
