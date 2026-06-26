# Profile principal: carga modular de profile.d/* (espejo del loop de ~/.bashrc).
# Cada modulo cubre una preocupacion (aliases, prompt, completado, etc.).

$profileD = Join-Path $PSScriptRoot 'profile.d'
if (Test-Path $profileD) {
    Get-ChildItem -Path $profileD -Filter '*.ps1' | Sort-Object Name | ForEach-Object {
        . $_.FullName
    }
}
