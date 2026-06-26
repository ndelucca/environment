#!/usr/bin/env pwsh

# Identidad de git + alias de gh (espejo de 00-git-bash.sh).
# La config portable (aliases, rebase, etc.) vive en dotfiles/git/gitconfig y se
# enlaza desde 04-link-configs via [include]; aca solo va lo propio de la maquina.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# gh puede devolver exit != 0 en casos benignos; no debe abortar el paso.
$PSNativeCommandUseErrorActionPreference = $false

git config --global user.name  'ndelucca'
git config --global user.email 'ndelucca@protonmail.com'

# gh: alias equivalente al de Fedora (gh co -> pr checkout).
if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh alias set co 'pr checkout' --clobber 2>$null
}
