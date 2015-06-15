# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 16-Jun-2015.

#requires -version 2.0

<#
.SYNOPSIS
    Associate file extensions to file types and commands

.DESCRIPTION
    Update-FileAssociation is powershell implementation of cmd.exe commands assoc and ftype
    in single command. If only Extension is specified as the argument, the function returns
    assocition information for given array of extensions. If either FileType or Command are
    specified, the given attribute will be updated.

.EXAMPLE
    assoc temp tempFile "`"$((gcm gvim).Definition)`" --remote-tab-silent %1" | fl

    Associate .temp extension to gvim and try to open files in a new tab of existing instance.

.EXAMPLE
    assoc html,txt | select -Expand Executable

    Get the list of associated programs for given extensions.

.NOTES
    Setting file association requires eleveated privileges.
#>
function Update-FileAssociation
{
    param(
        # Extension (with or without the dot) for which to get/set file type and associated command.
        [Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)]
        [string[]]$Extension,

        # File type to set for extension (if != $null). To erase specify empty string.
        [Parameter(ValueFromPipelineByPropertyName=$true, Mandatory=$false, Position=1)]
        [string]$FileType,

        # Command to set for extension (if != $null). To erase specify empty string.
        [Parameter(ValueFromPipelineByPropertyName=$true, Mandatory=$false, Position=2)]
        [string]$Command
    )

    $ErrorActionPreference = "Stop"
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ea ignore | Out-Null

    $result =  "" | select Extension, FileType, Command, Executable
    $results = @()

    function parse-command {$args[0]}
    $set  = "FileType","Command" | ? {$PSBoundParameters.Keys -contains $_ }
    foreach ($ext in $Extension)
    {
        $r = $result.PSObject.Copy()
        if (!$ext.StartsWith('.')) {$ext = ".$ext"}

        $r.Extension = $ext

        Write-Verbose "Reading registry for extension: $ext"
        $ftype = gp "HKCR:\$ext" -ea ignore
        if ($ftype) {
            $r.FileType = $ftype.'(default)'
            if ($r.FileType) {
                Write-Verbose "Reading registry for file type: $($r.FileType)"
                $assoc = gp "HKCR:\$($r.FileType)\shell\open\command" -ea ignore
                if ($assoc){ $r.Command = $assoc.'(default)' }
            }
        }

        if ($set) {
            if ($FileType -ne $null) {
                Write-Verbose "Setting file type for file extension: $ext"
                "HKCR:\$ext" | % {
                    mkdir $_ -ea ignore | Out-Null
                    sp $_ '(default)' ($r.FileType = $FileType)
                }
            }
            if ($Command -ne $null)  {
                Write-Verbose "Setting command for the file extension: $ext"
                "HKCR:\$FileType\shell\open\command" | % {
                    mkdir $_ -force -ea ignore| Out-Null
                    sp $_ '(default)' ($r.Command  = $Command)
                }
            }
        }

        $r.Executable =  iex "parse-command $($r.Command)"
        $results += $r
    }
    $results
}

sal assoc Update-FileAssociation

# Relevant docs
#https://msdn.microsoft.com/en-us/library/windows/desktop/ms724498(v=vs.85).aspx
