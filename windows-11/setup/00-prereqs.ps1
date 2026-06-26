#!/usr/bin/env pwsh

# Prerrequisitos: execution policy, winget, scoop y Developer Mode (para symlinks).

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Execution policy a nivel usuario para poder correr los scripts (idempotente).
if ((Get-ExecutionPolicy -Scope CurrentUser) -notin @('RemoteSigned', 'Unrestricted', 'Bypass')) {
    Write-Host 'Setting execution policy (CurrentUser -> RemoteSigned)...'
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
}

# winget viene con Win 11; si falta avisamos y abortamos el paso.
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget no esta disponible. Instalar "App Installer" desde Microsoft Store y reintentar.'
}
Write-Host "winget OK ($(winget --version))"

# scoop: gestor en espacio de usuario (sin admin) para herramientas CLI.
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host 'Installing scoop...'
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
}

# Buckets necesarios (extras: apps CLI; nerd-fonts: Cascadia Code NF).
$buckets = @(scoop bucket list | Select-Object -ExpandProperty Name)
foreach ($b in @('extras', 'nerd-fonts')) {
    if ($buckets -notcontains $b) {
        Write-Host "Adding scoop bucket: $b"
        scoop bucket add $b
    }
}

# Developer Mode: permite crear symlinks sin privilegios de admin (lo usa 04-link-configs).
# Requiere admin para escribir en HKLM; si falla, 04-link-configs cae a copiar archivos.
$devKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
try {
    $devVal = (Get-ItemProperty -Path $devKey -Name 'AllowDevelopmentWithoutDevLicense' -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
    if ($devVal -ne 1) {
        Write-Host 'Enabling Developer Mode (symlinks sin admin)...'
        New-Item -Path $devKey -Force | Out-Null
        Set-ItemProperty -Path $devKey -Name 'AllowDevelopmentWithoutDevLicense' -Value 1 -Type DWord
    }
} catch {
    Write-Warning 'No se pudo habilitar Developer Mode (correr como admin para symlinks). Se copiaran los configs en su lugar.'
}
