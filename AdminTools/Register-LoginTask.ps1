# Last Change: 2015-05-18.
# Author: M. Milic <miodrag.milic@gmail.com>

#requires -version 4.0

<#
.SYNOPSIS
    Registers login task for the current user using Task Scheduler.

.DESCRIPTION
    This function uses Task Scheduler to register login task or Powershell script
    for the current user. This is better then using Startup directory or registry RUN key
    because it has more options and behaves better with UAC. On the negative side, it
    requires elevated privileges.

    The function creates the task inside the $Env:USERNAME\Startup path.
#>
function Register-LoginTask()
{
    [CmdletBinding()]
    param(
        # Executable: Path to exe or Powershell script file (*.ps1)
        [Parameter(Mandatory=$true, ValueFromPipeline=$True, Position=0)]
        [Alias("Path", "FullName")]
        [string]$Execute,
        # Argument list to the program or script to execute
        [string[]]$ArgumentList,
        # Maximum value of random delay, 0 by default
        [timespan] $Delay=(New-Timespan),
        # Execution limit, by default indefinite (more precise, 27.7 years)
        [timespan] $Limit=(New-TimeSpan -Days 9999),
        # Run with highest privilege
        [switch]$RunElevated
    )

    if (!(Test-Path $Execute)) { throw "Invalid path: $Execute" }
    $script = (gi $Execute).Extension -eq '.ps1'

    $user = "$env:USERDOMAIN\$env:USERNAME"
    $a = New-ScheduledTaskAction -Execute $Execute -Argument "$ArgumentList"
    $t = New-ScheduledTaskTrigger -AtLogon -User $user -RandomDelay $Delay
    $s = New-ScheduledTaskSettingsSet -ExecutionTimeLimit $Limit  -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -Compatibility Win8 -StartWhenAvailable

    $params = @{
        Force    = $True
        TaskPath = "$user\Startup"
        Action   = $a
        Trigger  = $t
        Settings = $s
        Taskname = (Split-Path -Leaf $Execute)
    }
    if ($RunElevated) {$params.RunLevel="Highest"}
    if ($script) {
        $params.TaskName = "Powershell Login Script"
        $params.Action   = New-ScheduledTaskAction -Execute "$PSHome\powershell.exe" -Argument "-WindowStyle Hidden -NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File $ScriptPath $ArgumentList"
    }
    Register-ScheduledTask @params
}
