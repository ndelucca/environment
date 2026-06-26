#!/usr/bin/env pwsh

# Shell: modulos de PowerShell + stub del $PROFILE que carga el profile del repo
# (espejo de como .bashrc itera ~/.bashrc.d/*). El prompt (Starship) y el completado
# (PSReadLine) se configuran en dotfiles/powershell/profile.d/, no aca.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Galeria de PowerShell: posh-git (solo para tab-completion de git).
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}
foreach ($mod in @('posh-git')) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "Installing module: $mod"
        Install-Module -Name $mod -Scope CurrentUser -Force -AllowClobber
    }
}

# Stub idempotente en $PROFILE (pwsh 7: Documents\PowerShell\Microsoft.PowerShell_profile.ps1).
$WinDir      = Split-Path $PSScriptRoot -Parent
$RepoProfile = Join-Path $WinDir 'dotfiles\powershell\profile.ps1'

$marker = '# >>> nd.environment profile >>>'
$block  = @"
$marker
. '$RepoProfile'
# <<< nd.environment profile <<<
"@

$profileDir = Split-Path $PROFILE -Parent
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }

$content = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if (-not $content) { $content = '' }
if ($content -notmatch [regex]::Escape($marker)) {
    Add-Content -Path $PROFILE -Value "`n$block`n"
    Write-Host "Stub agregado a $PROFILE"
} else {
    Write-Host "Stub ya presente en $PROFILE"
}
