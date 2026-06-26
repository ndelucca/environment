# Completado (equivalente a .bashrc.d/03-completions.sh + opciones de readline del PS1).

# PSReadLine: historial predictivo + menu de completado con Tab.
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView -HistoryNoDuplicates
    Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# posh-git: solo tab-completion de git. El prompt lo maneja Starship, asi que no lo tocamos.
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
    $GitPromptSettings.EnablePromptStatus = $false
}

# gh: completado nativo.
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Invoke-Expression (& gh completion -s powershell | Out-String)
}

# winget: completado nativo.
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
        $word = $wordToComplete.Replace('"', '""')
        $ast  = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$word" --commandline "$ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
