#!/usr/bin/env pwsh

# Instalacion de paquetes (espejo de 03-apps.sh): winget (apps oficiales) + scoop (CLI).

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# winget/scoop devuelven codigos != 0 en casos benignos (ya instalado, sin upgrade);
# no queremos que eso aborte el paso.
$PSNativeCommandUseErrorActionPreference = $false

$SetupDir   = $PSScriptRoot
$WingetFile = Join-Path $SetupDir 'packages.json'
$ScoopFile  = Join-Path $SetupDir 'scoop-packages.txt'

# winget: import declarativo. Saltea lo ya instalado (idempotente).
Write-Host "Importing winget packages from $WingetFile..."
winget import --import-file $WingetFile `
    --accept-package-agreements --accept-source-agreements --ignore-versions --no-upgrade
if ($LASTEXITCODE -ne 0) {
    Write-Warning "winget import termino con codigo $LASTEXITCODE (suele ser por paquetes ya instalados)."
}

# scoop: lista de CLI tools. Mismo parseo que packages.txt: ignora # y lineas vacias.
$packages = Get-Content $ScoopFile |
    Where-Object { $_ -notmatch '^\s*(#|$)' } |
    ForEach-Object { $_.Trim() }

foreach ($pkg in $packages) {
    Write-Host "scoop install $pkg"
    scoop install $pkg   # idempotente: scoop avisa si ya esta instalado
}
