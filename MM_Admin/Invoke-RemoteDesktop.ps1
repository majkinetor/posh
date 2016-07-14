# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 14-Jul-2016.

#requires -version 2

<#
.SYNOPSIS
    Invokes remote desktop from command line and remembers credentials.
#>
function Invoke-RemoteDesktop {
    [CmdletBinding()]
    param(
        [string]$Server,
        [string]$User,
        [string]$Password,
        [switch]$Admin,
        [switch]$Fullscreen
    )

    cmdkey /generic:$Server /user:$User /pass:$Password

    $params = @("/v:$Server")
    if ($Admin) { $params += '/admin' }
    if ($Fullscreen)  { $params += '/f' }
    $cmd = "mstsc.exe $params"

    Write-Verbose $cmd
    iex $cmd
}

sal rdc Invoke-RemoteDesktop
