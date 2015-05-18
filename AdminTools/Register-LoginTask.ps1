# Last Change: 18-May-2015.
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
        # Executable to run
        [Parameter(ParameterSetName="Executable", Mandatory=$true, ValueFromPipeline=$True, Position=0)]
        [Alias("Path", "FullName")]
        [string]$Executable,
        # Path to the Powershell script to run.
        [Parameter(ParameterSetName="Script", Mandatory=$true, Position=0)]
        [string] $ScriptPath,
        # Maximum value of random delay, 0 by default
        [timespan] $Delay=(New-Timespan),
        # Execution limit, by default indefinite (more precise, 27.7 years)
        [timespan] $Limit=(New-TimeSpan -Days 9999),
        # Run with highest privilege
        [switch]$RunElevated
    )

    if ($Executable -and !(Test-Path $Executable)) { throw "Invalid path: $Executable" }

    $user = "$env:USERDOMAIN\$env:USERNAME"
    $a = New-ScheduledTaskAction -Execute $Executable
    $t = New-ScheduledTaskTrigger -AtLogon -User $user -RandomDelay $Delay
    $s = New-ScheduledTaskSettingsSet -ExecutionTimeLimit $Limit  -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -Compatibility Win8 -StartWhenAvailable

    $params = @{
        Force    = $True
        TaskPath = "$user\Startup"
        Action   = $a
        Trigger  = $t
        Settings = $s
        Taskname = (Split-Path -Leaf $Executable)
    }
    if ($RunElevated) {$params.RunLevel="Highest"}
    if ($Script) {
        if (!(Test-Path $Script)) {throw "Invalid script path: $Script"}
        $params.TaskName = "Powershell Login Script"
        $a = New-ScheduledTaskAction -Execute "$PSHome\powershell.exe" -Argument "-WindowStyle Hidden -NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File $ScriptPath"
    }
    Register-ScheduledTask @params
}
