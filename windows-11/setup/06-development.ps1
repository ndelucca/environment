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

# Verificacion del toolchain. Puede requerir abrir una terminal nueva para refrescar PATH.
$tools = @('go', 'node', 'npm', 'python', 'uv', 'git', 'gh', 'rg', 'fd', 'jq')
foreach ($t in $tools) {
    if (Get-Command $t -ErrorAction SilentlyContinue) {
        Write-Host ("  OK   {0}" -f $t)
    } else {
        Write-Warning ("  MISS {0} (no en PATH; reabri la terminal o revisa 01-packages)" -f $t)
    }
}

# Nota: el dev pesado adicional vive en WSL, donde aplica el setup bash de fedora-sway-spin.
