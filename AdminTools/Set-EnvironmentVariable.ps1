# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 03-Mar-2015.
#requires -version 1.0

<#
.SYNOPSIS
    Set enviornment variable
.EXAMPLE
    Set-EnvironmentVarable TMP "c:\Windows\TEMP" -Machine -Verbose

    Adds environment varible to the current console and registers it
    at the 'machine' level
.EXAMPLE
    Set-EnvironmentVarable PATH ";c:\Windows\TEMP" -Verbose -Append

    Appends value to the PATH variable
#>
function Set-EnvironmentVarable()
{
    [CmdletBinding(DefaultParameterSetName='Manual')]
    param(
        # Name of the environment variable, doesn't have to exist
        [string]$Name,
        # Value of the environment variable
        [string]$Value,
        # Set to create envirionment variable for the machine
        [switch]$Machine,
        # Set to append value to the existing value of environment variable
        [Parameter(ParameterSetName='Append',Position=1)]
        [switch]$Append,
        # Set to prepend value to the existing value of environment variable
        [Parameter(ParameterSetName='Prepend',Position=1)]
        [switch]$Prepend
    )
    $type = "User"
    if ($Machine) { $type = "Machine" }
    $old = [System.Environment]::GetEnvironmentVariable($Name, $type)

    if ($Append)  {$Value = "${old}${Value}" }
    if ($Prepend) {$Value = "${Value}${old}" }

    Set-Item Env:$name $value
    [System.Environment]::SetEnvironmentVariable($Name, $Value, $type)
    if ($old -ne $null) {
        Write-Verbose "$type environment variable changed."
        Write-Verbose "Previous value: $old"
    }
    else {
        Write-Verbsoe "$type environment variable created."
    }
}

Set-Alias env  Set-EnvironmentVariable
