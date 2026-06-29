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

# 4) Zed: deep-merge del template sobre el settings.json de %APPDATA%\Zed (espejo del
# render de Fedora). Zed reescribe settings.json en runtime (p. ej. wsl_connections),
# por eso NO se symlinkea: se mergea el template POR ENCIMA del existente para que el
# estado de runtime sobreviva y la config versionada gane sobre los defaults. keymap.json
# no lo reescribe Zed, asi que ese si va por symlink (Set-Config).
function Merge-ZedSettings {
    param([string]$Template, [string]$Dst)
    New-Item -ItemType Directory -Force -Path (Split-Path $Dst -Parent) | Out-Null

    # Primera corrida (sin settings previo) o sin jq: el template ES la config.
    if ((-not (Test-Path $Dst)) -or (-not (Get-Command jq -ErrorAction SilentlyContinue))) {
        Copy-Item -Path $Template -Destination $Dst -Force
        Write-Host "  zed settings.json (copiado del template)"
        return
    }

    # Zed escribe settings.json como JSONC y jq no parsea comentarios: limpiamos las
    # lineas que son solo comentario (patron de Zed) antes del merge.
    $tmpIn  = [System.IO.Path]::GetTempFileName()
    $tmpOut = [System.IO.Path]::GetTempFileName()
    (Get-Content $Dst) | Where-Object { $_ -notmatch '^\s*//' } | Set-Content $tmpIn -Encoding utf8

    # deep-merge: el template (.[1]) gana sobre lo existente (.[0]); las claves que solo
    # existen en el archivo de runtime (wsl_connections, etc.) se preservan.
    & jq -s '.[0] * .[1]' $tmpIn $Template > $tmpOut 2>$null
    if ($LASTEXITCODE -eq 0 -and (Get-Item $tmpOut).Length -gt 0) {
        Move-Item -Path $tmpOut -Destination $Dst -Force
        Write-Host "  zed settings.json (jq deep-merge)"
    } else {
        # Si el merge falla (JSON invalido), caemos en sobrescribir con el template.
        Copy-Item -Path $Template -Destination $Dst -Force
        Remove-Item -Path $tmpOut -Force -ErrorAction SilentlyContinue
        Write-Warning "  zed: jq fallo; settings.json sobrescrito con el template"
    }
    Remove-Item -Path $tmpIn -Force -ErrorAction SilentlyContinue
}

$zedSrc = Join-Path $Dotfiles 'zed'
$zedDst = Join-Path $env:APPDATA 'Zed'
if (Test-Path (Join-Path $zedSrc 'settings.json.in')) {
    Merge-ZedSettings -Template (Join-Path $zedSrc 'settings.json.in') -Dst (Join-Path $zedDst 'settings.json')
    Set-Config -Target (Join-Path $zedDst 'keymap.json') -Source (Join-Path $zedSrc 'keymap.json')
}

# 5) git: incluir la config portable del repo desde ~/.gitconfig (idempotente, no pisa).
$repoGitconfig = ((Join-Path $Dotfiles 'git\gitconfig') -replace '\\', '/')
$included = @(git config --global --get-all include.path 2>$null)
if ($included -notcontains $repoGitconfig) {
    git config --global --add include.path $repoGitconfig
    Write-Host "git include.path += $repoGitconfig"
} else {
    Write-Host 'git include.path ya presente'
}
