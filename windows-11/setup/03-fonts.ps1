#!/usr/bin/env pwsh

# Fuente Cascadia Code Nerd Font (los glyphs que usan prompt y terminal).

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false

# Desde el bucket nerd-fonts (agregado en 00-prereqs). Idempotente.
Write-Host 'Installing Cascadia Code NF...'
scoop install CascadiaCode-NF
