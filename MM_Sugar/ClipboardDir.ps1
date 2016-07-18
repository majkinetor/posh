#requires -version 5

function Set-ClipboardDir() { "$pwd" | Set-Clipboard }
function Get-ClipboardDir() {
    $item = Get-Clipboard
    if (!(Test-Path $item)) { throw "Clipboard item is not a valid path" }

    if (!(gi $item).PSIsContainer) { $item = Split-Path $item }
    pushd $item
}

sal cpushd Set-ClipboardDir
sal cpopd  Get-ClipboardDir
