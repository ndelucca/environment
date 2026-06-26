#!/usr/bin/env pwsh

# Orquestador del entorno Windows 11 (espejo de fedora-sway-spin/bootstraping.sh).
# Corre pasos numerados, idempotentes, con logging. Reejecutable sin romper.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Rutas detectadas desde la ubicacion del script (no hardcodear HOME ni el repo).
$WinDir   = $PSScriptRoot                       # ...\windows-11
$RepoDir  = Split-Path $WinDir -Parent          # ...\nd.environment
$SetupDir = Join-Path $WinDir 'setup'
$LogDir   = Join-Path $env:LOCALAPPDATA 'nd-bootstrap'
$LogFile  = Join-Path $LogDir "bootstrap-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path $LogFile -Append | Out-Null

$Steps = @(
    '00-prereqs.ps1'
    '01-packages.ps1'
    '02-git.ps1'
    '04-link-configs.ps1'
    '05-shell.ps1'
    '06-development.ps1'
)

$ok     = @()
$failed = @()

function Log($msg) { Write-Host "[bootstrap] $msg" }

# Submodulos (la config de nvim vive en un submodulo, compartido con fedora-sway-spin).
Log 'Initializing git submodules...'
try {
    git -C $RepoDir submodule update --init --recursive
} catch {
    Log "WARN no se pudieron inicializar submodulos: $($_.Exception.Message)"
}

foreach ($step in $Steps) {
    $file = Join-Path $SetupDir $step

    if (-not (Test-Path $file)) {
        Log "SKIP $step (not found)"
        $failed += "$step (missing)"
        continue
    }

    Log "RUN  $step"
    try {
        & $file
        $ok += $step
    } catch {
        Log "FAIL $step -> $($_.Exception.Message)"
        $failed += $step
    }
}

Write-Host ''
Log '===== Bootstrap summary ====='
foreach ($s in $ok)     { Log "  OK    $s" }
foreach ($s in $failed) { Log "  FAIL  $s" }
Log "Full log: $LogFile"

Stop-Transcript | Out-Null

if ($failed.Count -gt 0) {
    Log 'Some steps failed. Re-run bootstrap.ps1 to retry (steps are idempotent).'
    exit 1
}

Log 'Done. Abri una terminal nueva (PowerShell 7) para tomar el profile.'
