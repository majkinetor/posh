function Start-Powershell([switch]$As) {
    $cmd = 'start powershell'
    if ($RunAs) { $cmd += ' -Verb RunAs' }
    & $cmd
}
Set-Alias posh Start-Powershell
