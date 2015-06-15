# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 15-Jun-2015.

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

    Associate .temp extension to gvim and if possible start it in already open vim window.

.EXAMPLE
    assoc html,txt | select -Expand Executable

    Get the list of associated programs for given extensions.

.NOTE
    Setting file association requires eleveated privileges.
#>
function Update-FileAssociation
{
    param(
        # Extension (without the dot) for which to get/set file type and associated command.
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

    $set  = "FileType","Command" | ? {$PSBoundParameters.Keys -contains $_ }
    foreach ($ext in $Extension)
    {
        $r = $result.PSObject.Copy()
        $r.Extension = $ext

        Write-Verbose "Reading registry for extension: $ext"
        $ftype = gp "HKCR:\.$ext" -ea ignore
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
                "HKCR:\.$ext" | % {
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

        function parse-command {$args[0]}
        $r.Executable =  iex "parse-command $($r.Command)"
        $results += $r
    }
    $results
}

sal assoc Update-FileAssociation

assoc temp tempFile "`"$((gcm gvim).Definition)`" --remote-tab-silent %1" -Verbose | fl

#https://msdn.microsoft.com/en-us/library/windows/desktop/ms724498(v=vs.85).aspx
# ima smisla da bude i FileType nezavisno od Ext... recimo Drive i Directory
# videti kako se hendluje NoOpen
#https://msdn.microsoft.com/en-us/library/windows/desktop/ms724498(v=vs.85).aspx
#The NoOpen designation is for files that you don't want users to open. When the user double-clicks a file marked as NoOpen, the operating system will automatically provide a message informing the user that the file should not be opened. Note that if an action is later associated with a NoOpen file type, the NoOpen designation will be ignored.

#Pojavljuje se poruka 'you are attemtping to open file used by the system...'
