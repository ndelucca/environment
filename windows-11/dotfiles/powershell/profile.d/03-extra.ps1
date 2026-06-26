# Entorno Go (equivalente a .bashrc.d/05-extra.sh).
$env:GOPATH = "$HOME\dev\go"
if ($env:PATH -notlike "*$env:GOPATH\bin*") {
    $env:PATH = "$env:GOPATH\bin;$env:PATH"
}
