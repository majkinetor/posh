function ..  { cd .. }
function ... { cd ..\.. }
function e { exit }
function q { exit }

function posh { start powershell }

<# .SYNOPSIS
    Test for administration priv.
#>
function Test-Admin() {
    $usercontext = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $usercontext.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

<# .SYNOPSIS
    Converts hashtable to PSCustomObject so that cmdlets that require objects can be used.
#>
function o {
    param( [Parameter(ValueFromPipeline=$true)] [hashtable] $Hash)
    New-Object PSCustomObject -Property $Hash
}

<# .SYNOPSIS
    Expands powershell string.
   .EXAMPLE
    gc template.ps1 | expand
#>
function expand() {
    [CmdletBinding()]
    param ( [parameter(ValueFromPipeline = $true)] [string] $s)
    $ExecutionContext.InvokeCommand.ExpandString($s)
}

<# .SYNOPSIS
    Edit multiple files in $Env:EDITOR
   .EXAMPLE
    dir ..\*.txt | ed  .\my_file.txt

    Edit all text files from parent directory along with my_file.txt from current dir.
#>
function ed () { $f = $input + $args | gi | % { $_.fullname };  &$Env:EDITOR $f }

<# .SYNOPSIS
    Edit $PROFILE in $Env:EDITOR
#>
function edp { &$Env:EDITOR $PROFILE }

<# .SYNOPSIS
    Get current time in format ISO8601 yyyy-MM-ddTHH-mm-ss
#>
function now([switch]$fs) {[DateTime]::UtcNow.ToString("s").Replace(':','-')}

<# .SYNOPSIS
    Execute script in given directory or given files directory
#>
function in ($dir, $script) {
    if (Test-Path $dir -PathType Leaf) { $dir = Split-Path $dir -Parent }
    pushd $dir; & $script; popd
}

<# .SYNOPSIS
    Set current and working dir to the same one.
#>
function Set-WorkingDir([string] $Dir=$pwd) { cd $Dir; [IO.Directory]::SetCurrentDirectory($Dir) }

<# .SYNOPSIS
    List Powershell command parameters
#>
function params( $cmd ) {
    (gcm $cmd).ParameterSets.Parameters | select `
        Name,
        @{Name="Position";    Expression={if($_.Position -lt 0) {"-"} else {$_.Position}}},
        @{Name="Mandatory";   Expression={if ($_.IsMandatory) { "Yes" } else {""}}},
        @{Name="Type";        Expression={$_.ParameterType.Name}},
        "Aliases"
}
