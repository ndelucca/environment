# Prompt: Starship (equivalente al PS1 con __git_ps1). El tema vive en starship.toml,
# apuntado por STARSHIP_CONFIG (seteado en 04-link-configs).

if (Get-Command starship -ErrorAction SilentlyContinue) {
    $cfg = [Environment]::GetEnvironmentVariable('STARSHIP_CONFIG', 'User')
    if ($cfg) { $env:STARSHIP_CONFIG = $cfg }
    Invoke-Expression (&starship init powershell)
}
