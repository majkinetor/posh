# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 03-Mar-2015.

#requires -version 1.0

<#
.SYNOPSIS
    Runs a process / command as admin.

.DESCRIPTION
    Runs a process with elevated privileges. Has the ability to open a new
    powershell window. Can run legacy programs as admin cmd.

.EXAMPLE
    Start-ElevatedProcess

    Opens a new powershell window with administrative privileges.

.EXAMPLE
    Start-ElevatedProcess -Last -NoExit

    Runs the alst powershell command with adminsitrative privileges.

.EXAMPLE
    Start-ElevatedProcess {ps iexplore | kill}

    Opens a new powershell window with administrative privileges stops
    all internet explorer process.

.EXAMPLE
    Start-ElevatedProcess -Program notepad -Command {C:\Windows\System32\Drivers\etc\hosts}

    Opens the host file as admin in notepad.exe.

.INPUTS
    System.Management.Automation.ScriptBlock,System.String

.OUTPUTS
    $null

#>
function Start-ElevatedProcess {
    [CmdletBinding(DefaultParameterSetName='Manual')]
    param(
        # Optional script block to execute. Can be argument for legacy cmd.
        [Parameter(ParameterSetName='Manual',Position=0)]
        [System.Management.Automation.ScriptBlock]
        $Command,

        # Optional application to elevate. Default value = Powershell.exe
        [Parameter(ParameterSetName='Manual',Position=1)]
        [System.String]
        $Program = (Join-Path -Path $PsHome -ChildPath 'powershell.exe'),

        # Option switch. Run previous powershell command as admin.
        [Parameter(ParameterSetName='History')]
        [switch]
        $Last,

        # Option Switch. Leave the eveleated powershell window open.
        [Parameter(ParameterSetName='History')]
        [Parameter(ParameterSetName='Manual')]
        [Parameter(ParameterSetName='Script')]
        [switch]
        $NoExit,

        # Optional path to script file.
        [Parameter(ParameterSetName='Script')]
        [ValidateScript({if(Test-Path -Path $_ -PathType Leaf){ $true } else{Throw "$_ is not a valid Path"}})]
        [system.String]
        $Script
    )

    $startArgs = @{
        FilePath = $Program
        Verb = 'RunAs'
        ErrorAction = 'Stop'
    }

    if($last){
        $LastCommand = Get-History | Select-Object -ExpandProperty CommandLine -Last 1
        $ArgList = "-command $lastCommand"
    }

    elseif($command -and $program -match 'powershell.exe$'){
        $ArgList = " -command $command "
    }

    elseif($script){
        $script = Resolve-Path -Path $script
        $ArgList = " -file '$script'"
    }

    elseif($Command){
        $ArgList = "$command"
    }

    if($NoExit -and $program -match 'powershell.exe$'){
        $ArgList = '-NoExit',$ArgList -join " "
    }

    if($ArgList){
        Write-Verbose -Message "Command line: $ArgList"
        $startArgs.Add('ArgumentList',$ArgList)
    }

    Start-Process @StartArgs
}

Set-Alias sudo Start-ElevatedProcess
