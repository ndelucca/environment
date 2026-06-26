# Aliases basicos (equivalentes a .bashrc.d/00-aliases.sh).

function ll { Get-ChildItem -Force @args }      # ls -l
function la { Get-ChildItem -Force @args }      # ls -A
function l  { Get-ChildItem @args }             # ls -CF

function myip {
    Write-Host -NoNewline 'external: '
    Invoke-RestMethod -Uri 'https://ifconfig.me/ip'
    Write-Host ''
    Write-Host -NoNewline 'local: '
    (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.PrefixOrigin -ne 'WellKnown' } |
        Select-Object -ExpandProperty IPAddress) -join ' '
}
