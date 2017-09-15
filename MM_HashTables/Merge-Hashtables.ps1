#requires -Version 2.0
<#
.SYNOPSIS
    Create new HashTable from two HashTables where the second given
    HashTable will override.

.DESCRIPTION
    In case of duplicate keys the second HashTable's key values "win".     
    Nested and ordered HashTables are supported. Ordered HashTables are s

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
        $First,

        # Overriding HashTable
        $Second
    )

    function set_keys ($First, $Second)
    {
        @($First.Keys) | ? { $Second.Keys -contains $_ } | % {
            if ( is_HashTable $First.$_ $Second.$_ ) { set_keys $First.$_ $Second.$_ }
            else {
                $First.$_ = $Second.$_
            }
        }
    }

    function add_keys ($First, $Second)
    {
        @($Second.Keys) | % {
            if ($First.Keys -contains $_) {
                if (is_HashTable $Second.$_ $First.$_) { add_keys $First.$_ $Second.$_ }
            } else { $First.$_ = $Second.$_ }
        }
    }

    function clone( $DeepCopyObject )  
    {
        if (!$DeepCopyObject) { return $DeepCopyObject }        
        $memStream = new-object IO.MemoryStream
        $formatter = new-object Runtime.Serialization.Formatters.Binary.BinaryFormatter
        $formatter.Serialize($memStream,$DeepCopyObject)
        $memStream.Position=0
        $formatter.Deserialize($memStream)
    }

    function is_HashTable() {
        foreach ($h in $args) { 
            $b = ($h -is [HashTable]) -or ($h -is [System.Collections.Specialized.OrderedDictionary])
            if (!$b) { return $false }
        }
        return $true
    }
    
    if (!$Second) { return (clone $First) }
    if (!$First)  { return (clone $Second) }

    $firstClone  = clone $First
    $secondClone = clone $Second

    set_keys $firstClone $secondClone
    add_keys $firstClone $secondClone

    $firstClone
}

# $a = [ordered]@{
#     x = 1
#     y = 2
#     z = [ordered]@{
#         z1=1
#         z2=2
#     }
# }

# $b = [ordered] @{
#     x = 'a'    
#     z = [ordered]@{ z2='a'}
#     k = 'a'
# }


# $c = Merge-Hashtables $a $b
# $c 