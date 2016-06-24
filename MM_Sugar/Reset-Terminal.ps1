<#
.SYNOPSIS
    Reset terminal colors and clear the screen
#>
function Reset-Terminal() {
    [Console]::ResetColor()
    cls
}
