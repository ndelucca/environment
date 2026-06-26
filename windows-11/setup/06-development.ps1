#!/usr/bin/env pwsh

# Entorno de desarrollo (dev mixto Windows+WSL): estructura de dirs + verificacion
# del toolchain (espejo de 06-development.sh). Los lenguajes se instalan en 01-packages.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Estructura de directorios (espejo de Fedora).
$dirs = @(
    "$HOME\dev\go\src"
    "$HOME\dev\go\bin"
    "$HOME\dev\go\pkg"
    "$HOME\dev\node"
    "$HOME\dev\python"
)
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
Write-Host 'dev dirs OK'

# Refrescamos el PATH del proceso desde el registro (Machine + User) antes de verificar:
# winget/scoop modifican el PATH persistente pero no el del proceso ya corriendo, asi
# la verificacion no reporta MISS por herramientas recien instaladas (node, etc.).
$env:PATH = (
    [Environment]::GetEnvironmentVariable('PATH', 'Machine'),
    [Environment]::GetEnvironmentVariable('PATH', 'User')
) -join ';'

# Verificacion del toolchain. Aun asi, conviene abrir una terminal nueva para uso normal.
$tools = @('go', 'node', 'npm', 'python', 'uv', 'git', 'gh', 'rg', 'fd', 'jq')
foreach ($t in $tools) {
    if (Get-Command $t -ErrorAction SilentlyContinue) {
        Write-Host ("  OK   {0}" -f $t)
    } else {
        Write-Warning ("  MISS {0} (no en PATH; reabri la terminal o revisa 01-packages)" -f $t)
    }
}

# Nota: el dev pesado adicional vive en WSL, donde aplica el setup bash de fedora-sway-spin.
