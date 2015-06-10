# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 18-May-2015.

#requires -version 2

<#
.SYNOPSIS
    Runs a process / command as admin.

.DESCRIPTION
    Runs a process with elevated privileges. Has the ability to open a new
    powershell window. Can run legacy programs as admin cmd.

.EXAMPLE
    sudo

    Opens a new powershell window with the administrative privileges and sets
    the current directory to the one of the calling shell.

.EXAMPLE
    sudo -Last -NoExit

    Runs the last powershell command with the adminsitrative privileges and
    keeps the shell from closing.

.EXAMPLE
    Start-ElevatedProcess {ps iexplore | kill} -Wait -WindowStyle Hidden

    Opens a new powershell window with administrative privileges to stops all
    internet explorer process. Wait for action to return but hide the window.

.EXAMPLE
    Start-ElevatedProcess  {C:\Windows\System32\Drivers\etc\hosts} -Program notepad

    Opens the host file as admin in notepad.exe.

#>
function Start-ElevatedProcess {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        # Optional script block to execute or a program argument
        [Parameter(Position=0, ParameterSetName='command')]
        [scriptblock] $Command,

        # Optional application to elevate, by default 'powershell.exe'.
        [Parameter(Position=1)]
        [string] $Program = (Join-Path -Path $PsHome -ChildPath 'powershell.exe'),

        # Path to script file, Program must be 'powershell.exe' or 'cmd.exe'.
        [Parameter(Position=0, ParameterSetName='script')]
        [ValidateScript({if(Test-Path -Path $_ -PathType Leaf){ $true } else{Throw "$_ is not a valid Path"}})]
        [string] $Script,

        # Run previous powershell command as admin. Commands starting with 'sudo' and 'Start-ElevatedProcess' are ignored.
        [Parameter(ParameterSetName='last')]
        [switch] $Last,

        # Leave the eveleated 'powershell.exe' or 'cmd.exe' window open.
        [Parameter(ParameterSetName='last')]
        [Parameter(ParameterSetName='command')]
        [Parameter(ParameterSetName='script')]
        [switch] $NoExit,

        # Wait for process to exit before returning
        [switch] $Wait,

        # Window style: Normal, Maximized, Minimized or Hidden
        [ValidateSet('Normal','Maximized','Minimized','Hidden')]
        [string] $WindowStyle = 'Normal'
    )

    $params = @{
        #WorkingDirectory = $pwd         #doesn't work with RunAs verb so I used 'cd $pwd' with command
        FilePath         = $Program
        Verb             = 'RunAs'
        ErrorAction      = 'Stop'
        Wait             = $false
        WindowStyle      = $WindowStyle
    }

    $argList = @()
    if ($program -match '[\\]?powershell(.exe)?$') {
        if ($NoExit -or (!$Command -and !$Script -and !$Last))  { $argList += '-NoExit' }

        $cmd = '-Command "' + "cd '$pwd'" + '"'
        if ($Command) { $cmd += "; {0}" -f $Command }
        if ($Last)    {
            $l = h | sort -Desc | ? { $_.CommandLine -notmatch '^\s*(sudo|Start-ElevatedProcess)\s*' } | select -First 1 -Expand CommandLine
            $cmd += "; {0}" -f $l
        }
        $argList += $cmd

        if ($Script)  { $argList += "-File ""{0}""" -f (Resolve-Path $script) }
    }
    elseif($program -match '[\\]?cmd(.exe)?$'){
        $a = '/C';
        if ($NoExit)  { $a = '/K' }
        if ($Command) { $argList += "$a ""cd ""$pwd"" & $command""" }
        if ($Script)  { $argList += "$a ""{0}""" -f (Resolve-Path $script) }
    }
    else {
        if ($Command) { $argList += $Command }
    }

    if ($Wait) { $params.Wait = $true }

    if ($argList -and $argList.Count) { $params.ArgumentList = $argList }
    Write-Verbose $($params | out-string)
    Start-Process @params
}

Set-Alias sudo Start-ElevatedProcess
