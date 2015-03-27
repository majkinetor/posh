#requires -version 2.0

<#
.Synopsis
    Convert an object into a hashtable.
.Description
    This command will take an object and create a hashtable based on its properties.
    You can have the hashtable exclude some properties as well as properties that
    have no value.
.Example
    PS C:\> get-process -id $pid | select name,id,handles,workingset | ConvertTo-HashTable

    Name                           Value
    ----                           -----
    WorkingSet                     418377728
    Name                           powershell_ise
    Id                             3456
    Handles                        958
.Notes
    Version:  2.0
    Updated:  January 17, 2013
    Author :  Jeffery Hicks (http://jdhitsolutions.com/blog)
    Modified: M Milic.
.Link
    About_Hash_Tables
.Inputs
    Object
.Outputs
    HashTable
#>

Function ConvertTo-HashTable {

[CmdletBinding()]
Param(
    [Parameter(Position=0,Mandatory=$True, HelpMessage="Please specify an object",ValueFromPipeline=$True)]
    [ValidateNotNullorEmpty()]
    # A PowerShell object to convert to a hashtable.
    [object]$InputObject,
    # Do not include object properties that have no value.
    [switch]$NoEmpty,
    # An array of property names to exclude from the hashtable.
    [string[]]$Exclude
)

Process {
    #get type using the [Type] class because deserialized objects won't have
    #a GetType() method which is what we would normally use.

    $TypeName = [system.type]::GetTypeArray($InputObject).name
    Write-Verbose "Converting an object of type $TypeName"

    $names = $InputObject | gm -MemberType properties | select -expand name
    $hash = @{}
    $names | % {
        if ($Exclude -notcontains $_) {
            if ($NoEmpty -and -not ($inputobject.$_)) {
                Write-Verbose "Skipping $_ as empty"
            }
            else {
                Write-Verbose "Adding property $_"
                $hash.Add($_,$inputobject.$_)
            }
        } else { Write-Verbose "Excluding $_" }
    }  Write-Verbose "Writing the result to the pipeline"
    $hash
 }
}
