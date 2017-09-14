#requires -Version 2.0
<#
.SYNOPSIS
    Create new HashTable from two HashTables where the second given
    HashTable will override.

.DESCRIPTION
    In case of duplicate keys the second HashTable's key values "win". 
    Nested HashTables are supported.

.EXAMPLE
    $configData = Merge-Hashtables -First $defaultData -Second $overrideData

.INPUTS
    None

.OUTPUTS
    System.Collections.Hashtable
#>
function Merge-Hashtables
{
    [CmdletBinding()]
    param (
        # Base HashTable
        [Hashtable] $First,

        # Overriding HashTable
        [Hashtable] $Second
    )

    function Set-Keys ($First, $Second)
    {
        @($First.Keys) | ? { $Second.ContainsKey($_) } | % {
            if (($First.$_ -is [Hashtable]) -and ($Second.$_ -is [Hashtable])) {
                Set-Keys -First $First.$_ -Second $Second.$_
            }
            else {
                $First.Remove($_)
                $First.Add($_, $Second.$_)
            }
        }
    }

    function Add-Keys ($First, $Second)
    {
        @($Second.Keys) | % {
            if ($First.ContainsKey($_)) {
                if (($Second.$_ -is [Hashtable]) -and ($First.$_ -is [Hashtable])) {
                    Add-Keys -First $First.$_ -Second $Second.$_
                }
            }
            else {
                $First.Add($_, $Second.$_)
            }
        }
    }

    function clone( $DeepCopyObject )  {
        if (!$DeepCopyObject) { return $DeepCopyObject }        
        $memStream = new-object IO.MemoryStream
        $formatter = new-object Runtime.Serialization.Formatters.Binary.BinaryFormatter
        $formatter.Serialize($memStream,$DeepCopyObject)
        $memStream.Position=0
        $formatter.Deserialize($memStream)
    }
    
    if (!$Second) { return (clone $First) }
    if (!$First)  { return (clone $Second) }

    $firstClone  = clone $First
    $secondClone = clone $Second

    Set-Keys -First $firstClone -Second $secondClone
    Add-Keys -First $firstClone -Second $secondClone

    $firstClone
}
