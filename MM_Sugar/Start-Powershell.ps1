function Start-Powershell([switch]$As) {
    $cmd = 'start powershell'
    if ($RunAs) { $cmd += ' -Verb RunAs' }
    iex $cmd
}
Set-Alias posh Start-Powershell
