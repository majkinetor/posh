# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 23-Jun-2016.

<#
.Synopsis
    Set Windows to automatically login as given user after restart and eventually execute a script

.Description
    Enable AutoLogon next time when the server reboots.
    It can trigger a specific Script to execute after the server is back online after Auto Logon.

.Example
    Set-AutoLogon -Username "win\admin" -Password "password123"

.Example
    Set-AutoLogon -Username "win\admin" -Password "password123" -LogonCount "3"


.EXAMPLE
    Set-AutoLogon -Username "win\admin" -Password "password123" -Script "c:\test.bat"
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

        #Sets the number of times the system would reboot without asking for credentials.
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

    $v = if ($LogonCount)  { $LogonCount } else { '' }
    Set-ItemProperty $RegPath "AutoLogonCount" -Value $v -Type DWord

    $v = if ($Script)  { $Script } else { '' }
    Set-ItemProperty $RegROPath "(Default)" -Value $v
}
