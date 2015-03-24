# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 14-Mar-2015.

#requires -version 2.0

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
function Set-EnvironmentVariable()
{
    [CmdletBinding(DefaultParameterSetName='Manual')]
    param(
        # Name of the environment variable, it doesn't have to exist
        [string]$Name,
        # Value of the environment variable
        [string]$Value,
        # Set to create environment variable for the machine instead for the current user
        [switch]$Machine,
        # Set to append Value to the existing value of the environment variable
        [switch]$Append,
        # Set to prepend a Value to the existing one of the environment variable
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
        Write-Verbose "$type environment variable created."
    }
}

Set-Alias env  Set-EnvironmentVariable
