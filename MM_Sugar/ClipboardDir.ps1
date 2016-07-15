#requires -version 5

function Set-ClipboardDir() { "$pwd" | Set-Clipboard }
function Get-ClipboardDir() { Get-Clipboard | cd }

sal cpushd Set-ClipboardDir
sal cpopd Get-ClipboardDir
