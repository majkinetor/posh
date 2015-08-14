#requires -version 2.0
<#
.Synopsis
    Convert an object into a hashtable.
.Description
    This command will take an object and create a hashtable based on its properties.
    You can have the hashtable exclude some properties as well as properties that
    have no value.
.Notes
    Author: Miodrag Milic <miodrag.milic@gmail.com>
    Last Change: 27-Mar-2015.
.Example
    get-process -id $pid | select name,id,handles,workingset | ConvertTo-HashTable

    Name                           Value
    ----                           -----
    WorkingSet                     418377728
    Name                           powershell_ise
    Id                             3456
    Handles                        958
.Link
    About_Hash_Tables
.Inputs
    Object
.Outputs
    HashTable
#>

function ConvertTo-HashTable {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0,Mandatory=$True, HelpMessage="Please specify an object",ValueFromPipeline=$True)]
        [ValidateNotNullorEmpty()]
        # A PowerShell object to convert to a hashtable. If hashtable is passed, simply return it.
        [object]$InputObject,
        # Do not include object properties that have no value.
        [switch]$NoEmpty,
        # An array of property names to exclude from the hashtable.
        [string[]]$Exclude
    )

    Process {

        $TypeName = [system.type]::GetTypeArray($InputObject).name  # Deserialized objects won't have a GetType() method
        if ($TypeName -eq [HashTable]) { return $InputObject }

        Write-Verbose "Converting an object of type $TypeName"

        $names = $InputObject | gm -MemberType properties | select -expand name
        $hash = @{}
        $names | % {
            if ($Exclude -contains $_) { return }
            if ($NoEmpty -and -not ($inputobject.$_)) { Write-Verbose "Skipping empty $_ "; return }

            Write-Verbose "Adding property $_"
            $hash.Add($_,$inputobject.$_)
        }
        $hash
    }
}
