# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 23-Jun-2016.

<#
.SYNOPSIS
    Set Windows to automatically login as given user after restart and eventually execute a script

.DESCRIPTION
    Enable AutoLogon next time when the server reboots.
    It can trigger a specific Script to execute after the server is back online after Auto Logon.

.EXAMPLE
    Set-AutoLogon -Username "domain\user" -Password "my password"

.EXAMPLE
    Set-AutoLogon -Username "domain\user" -Password "my password" -LogonCount 3

.EXAMPLE
    Set-AutoLogon -Username "domain\user" -Password "my password" -Script "c:\test.bat"
#>

function Set-AutoLogon {
    [CmdletBinding()]
    Param(
        #Provide the username that the system would use to login.
        [Parameter(Mandatory=$true)]
        [String]$Username,

        #Provide the Password for the User provided.
        [Parameter(Mandatory=$true)]
        [String]$Password,

        #Sets the number of times the system would reboot without asking for credentials, by default 100000.
        [String]$LogonCount=100000,

        #Script: Provide Full path of the script for execution after server reboot
        [String]$Script
    )

    $ErrorActionPreference = 'Stop'

    $RegPath   = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $RegROPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"

    Set-ItemProperty $RegPath "AutoAdminLogon"  -Value 1
    Set-ItemProperty $RegPath "DefaultUsername" -Value $Username
    Set-ItemProperty $RegPath "DefaultPassword" -Value $Password
    #Set-ItemProperty $RegPath "DefaultDomain" -Value $Env:USERDOMAIN

    $v = if ($LogonCount)  { $LogonCount } else { '' }
    Set-ItemProperty $RegPath "AutoLogonCount" -Value $v -Type DWord

    $v = if ($Script)  { $Script } else { '' }
    Set-ItemProperty $RegROPath "Set-Autologon" -Value $v
}
