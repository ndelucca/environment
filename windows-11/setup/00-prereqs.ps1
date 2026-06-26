#!/usr/bin/env pwsh

# Prerrequisitos: execution policy, winget, scoop y Developer Mode (para symlinks).

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Execution policy a nivel usuario para poder correr los scripts (idempotente).
# Si la policy efectiva ya permite correr scripts (LocalMachine RemoteSigned, etc.)
# no hace falta tocar nada. Set-ExecutionPolicy puede lanzar SecurityException en
# algunos entornos (GPO/registro): no debe abortar el bootstrap, es solo conveniencia.
$permisivas = @('RemoteSigned', 'Unrestricted', 'Bypass')
if ((Get-ExecutionPolicy) -notin $permisivas) {
    Write-Host 'Setting execution policy (CurrentUser -> RemoteSigned)...'
    try {
        Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
    } catch {
        Write-Warning "No se pudo setear execution policy: $($_.Exception.Message). Corre con 'pwsh -ExecutionPolicy Bypass -File ...' si los scripts no arrancan."
    }
} else {
    Write-Host "Execution policy OK (efectiva: $(Get-ExecutionPolicy))"
}

# winget viene con Win 11; si falta avisamos y abortamos el paso.
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget no esta disponible. Instalar "App Installer" desde Microsoft Store y reintentar.'
}
Write-Host "winget OK ($(winget --version))"

# scoop: gestor en espacio de usuario (sin admin) para herramientas CLI.
# El chequeo no puede depender solo del PATH: si scoop ya esta instalado pero el
# PATH del proceso no se refresco (terminal vieja), reinstalar falla con
# "destination path already exists". Detectamos tambien por la carpeta de instalacion
# y, si existe, agregamos sus shims al PATH del proceso para que los pasos siguientes
# (scoop install) funcionen sin reabrir la terminal.
$scoopShims = Join-Path $env:USERPROFILE 'scoop\shims'
$scoopInstalled = (Get-Command scoop -ErrorAction SilentlyContinue) -or (Test-Path (Join-Path $scoopShims 'scoop.ps1'))
if (-not $scoopInstalled) {
    Write-Host 'Installing scoop...'
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
}
if ((Test-Path $scoopShims) -and (($env:PATH -split ';') -notcontains $scoopShims)) {
    $env:PATH = "$scoopShims;$env:PATH"
}

# Buckets necesarios (extras: apps CLI).
$buckets = @(scoop bucket list | Select-Object -ExpandProperty Name)
foreach ($b in @('extras')) {
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
