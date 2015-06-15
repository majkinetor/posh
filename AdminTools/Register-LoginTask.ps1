# Last Change: 15-Jun-2015.
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

    The function creates the task inside the $Env:USERDOMAIN\$Env:USERNAME\Startup path.

.EXAMPLE
    Register-LoginTask "$Env:PROGRAMFILES\Everything\Everything.exe" -Arguments '-startup' -RunElevated -Delay "00:00:30"

    Starts everything.exe minimized in elevated mode with random 30 second delay.

.EXAMPLE
    '"Hello $($args[0])" > out.txt; ' > test.ps1
    Register-LoginTask test.ps1 -Arguments 'Foo Bar' -Verbose

    Register login script with arguments. Show Powershell arguments in verbose output.

.EXAMPLE
    Get-ScheduledTask -TaskPath \$Env:USERDOMAIN\$Env:USERNAME\*

    List all registered tasks for the user.

.EXAMPLE
    Get-ScheduledTask -TaskPath \$Env:USERDOMAIN\$Env:USERNAME\* | select -First 1 | Unregister-ScheduledTask

    Unregister first scheduled task for the user.

#>
function Register-LoginTask()
{
    [CmdletBinding()]
    param(
        # Executable: Path to exe or Powershell script file (*.ps1)
        [Parameter(Mandatory=$true, ValueFromPipeline=$True, Position=0)]
        [Alias("Path", "FullName")]
        [string]$Execute,
        # Arguments to the program or script to execute
        [string]$Arguments,
        # Maximum value of random delay, 0 by default
        [timespan] $Delay=(New-Timespan),
        # Execution limit, by default indefinite (more precise, 27.7 years)
        [timespan] $Limit=(New-TimeSpan -Days 9999),
        # Run with highest privilege
        [switch]$RunElevated
    )

    if (!(Test-Path $Execute)) { throw "Invalid path: $Execute" }
    $isScript = (gi $Execute).Extension -eq '.ps1'

    $user = "$env:USERDOMAIN\$env:USERNAME"
    $params = @{ Execute = $Execute }
    if (![string]::IsNullOrWhiteSpace($Arguments)) { $params.Argument = $Arguments }
    $a = New-ScheduledTaskAction @params
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
    if ($isScript) {
        $params.TaskName = "PS - $(Split-Path -Leaf $Execute)"
        $scriptPath = Resolve-Path $Execute
        $sa = "-NoProfile -NoLogo -WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -Command `"cd `$HOME; . '$scriptPath' $Arguments`""
        Write-Verbose "Registering login script. Powershell arguments:`n$sa"
        $params.Action = New-ScheduledTaskAction -Execute "$PSHome\powershell.exe" -Argument $sa
    } else { Write-Verbose "Registering login executable:`n$Execute $Arguments" }

    Register-ScheduledTask @params
}
