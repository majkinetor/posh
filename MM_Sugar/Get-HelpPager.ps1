# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 30-Mar-2016.

<#
.SYNOPSIS
    Get full help and display it in a pager (less.exe)

.EXAMPLE
    PS> m gcm

    Get full help for gcm command

.NOTE
    Depends on less. Install it via chocolatey: cinst less
#>

function Get-HelpPager() {
    if (!(gcm less.exe -ea 0)) { throw "Please install less: cinst less" }

    get-help "$args" -Full | less.exe
}
