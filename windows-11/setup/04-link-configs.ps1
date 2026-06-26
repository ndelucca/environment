#!/usr/bin/env pwsh

# Despliegue de configs (reemplazo de stow). Usa symlinks cuando hay Developer Mode
# y cae a copiar si no. No copia archivos al repo: apunta a los del repo.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# git config --get-all devuelve exit 1 cuando la clave no existe; no debe abortar.
$PSNativeCommandUseErrorActionPreference = $false

$WinDir   = Split-Path $PSScriptRoot -Parent      # ...\windows-11
$RepoDir  = Split-Path $WinDir -Parent            # ...\nd.environment
$Dotfiles = Join-Path $WinDir 'dotfiles'

# Crea un symlink; si no hay permiso (sin Developer Mode/admin) copia el archivo.
function Set-Config {
    param([string]$Target, [string]$Source)
    $parent = Split-Path $Target -Parent
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        Write-Host "  link $Target -> $Source"
    } catch {
        Copy-Item -Path $Source -Destination $Target -Force
        Write-Warning "  symlink fallo (sin Developer Mode?); copiado: $Target"
    }
}

# 1) Starship: variable de usuario STARSHIP_CONFIG -> toml del repo.
$starshipCfg = Join-Path $Dotfiles 'starship\starship.toml'
[Environment]::SetEnvironmentVariable('STARSHIP_CONFIG', $starshipCfg, 'User')
$env:STARSHIP_CONFIG = $starshipCfg
Write-Host "STARSHIP_CONFIG -> $starshipCfg"

# 2) Windows Terminal: settings.json (equivalente a foot.ini).
$wtState = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'
if (Test-Path $wtState) {
    Set-Config -Target (Join-Path $wtState 'settings.json') -Source (Join-Path $Dotfiles 'windows-terminal\settings.json')
} else {
    Write-Warning 'Windows Terminal no encontrado. Abrilo una vez y reejecuta 04-link-configs.ps1.'
}

# 3) Neovim: config compartida (submodulo de fedora-sway-spin) -> %LOCALAPPDATA%\nvim.
$nvimSrc = Join-Path $RepoDir 'fedora-sway-spin\dotfiles\.config\nvim'
$nvimDst = Join-Path $env:LOCALAPPDATA 'nvim'
if (Test-Path $nvimSrc) {
    $existing = Get-Item $nvimDst -Force -ErrorAction SilentlyContinue
    # Ya es un symlink: si apunta a otro lado lo recreamos, si ya apunta bien no hacemos nada.
    if ($existing -and $existing.LinkType -eq 'SymbolicLink') {
        if ($existing.Target -eq $nvimSrc) {
            Write-Host "  link $nvimDst -> $nvimSrc (ya presente)"
            $existing = $null
        } else {
            Remove-Item $nvimDst -Force
            $existing = $null
        }
    }
    # Directorio/archivo real preexistente: lo respaldamos en vez de pisarlo (New-Item -Force
    # no puede reemplazar un directorio real no vacio, y no queremos perder una config local).
    if ($existing) {
        $bak = "$nvimDst.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Move-Item -Path $nvimDst -Destination $bak -Force
        Write-Warning "  nvim ya existia como copia real; respaldado en $bak"
    }
    if (-not (Test-Path $nvimDst)) {
        try {
            New-Item -ItemType SymbolicLink -Path $nvimDst -Target $nvimSrc -Force | Out-Null
            Write-Host "  link $nvimDst -> $nvimSrc"
        } catch {
            Write-Warning "No se pudo linkear nvim ($nvimDst). Requiere Developer Mode/admin."
        }
    }
}

# 4) git: incluir la config portable del repo desde ~/.gitconfig (idempotente, no pisa).
$repoGitconfig = ((Join-Path $Dotfiles 'git\gitconfig') -replace '\\', '/')
$included = @(git config --global --get-all include.path 2>$null)
if ($included -notcontains $repoGitconfig) {
    git config --global --add include.path $repoGitconfig
    Write-Host "git include.path += $repoGitconfig"
} else {
    Write-Host 'git include.path ya presente'
}
