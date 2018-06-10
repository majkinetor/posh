#require -version 3

<#
.SYNOPSIS 
    Invoke control papnel item by filtering out the item list with fuzzy search
#>
function Invoke-ControlPanelItem() { 
    if (!(gcm fzf -ea 0)) { Write-Host "To use this function, install fzf first: cinst fzf"; return }
    Get-ControlPanelItem  | % name | sort | fzf --reverse | Show-ControlPanelItem 
}

sal control Invoke-ControlPanelItem