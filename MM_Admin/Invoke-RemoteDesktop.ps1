# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 15-Mar-2017.

#requires -version 2

<#
.SYNOPSIS
    Invokes remote desktop from command line and remembers credentials.
.NOTES
    Might not work with complain about identity of the server:
    Your system administrator does not allow the use of saved credentials to log on to remote computer because identity is not fully verified
    http://serverfault.com/questions/396722/your-system-administrator-does-not-allow-the-use-of-saved-credentials-to-log-on
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
