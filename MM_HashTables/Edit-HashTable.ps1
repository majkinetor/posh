<#
.SYNOPSIS
    Transform given hashtable via deep iterator to new hashtable

.DESCRIPTION
    Provide a scriptblock that processes each element of an existing hashtable. Change, add or remove elements by 
returning array of key/value pairs.

.PARAMETER Hash
    ([ordered]) Hashtable to be transformed

.PARAMETER Action
    ScriptBlock to call on each element. Accepts arguments $key, $value, $parent. Parent is array of parent based on hierarchy.
    Returns array (key, val, key1, val1, .... keyN, valN).
    First 2 will be used instead of the original key/val pairs. Pass $null as key to delete the key/value pair in the resulting table.
    Other keys (1..N) will be addeded to resulting table.
    
    If value is an [Array] and $EnumerateArrays switch is present, the Action will get called with the $key parameter set to $null and the $value parameter set to array value.
    Return $false to remove array item from resulting array or ($true, $item1 ... $itemN) to replace the current $value with $items[1..N].

.EXAMPLE
    Edit-HashTable @{x=1; y=2; z=@{p=3}} { param( $key, $value ) $key.ToUpper(), $value  }

    Transform keys to uppercase

.EXAMPLE
    Edit-HashTable ([ordered]@{x=1; y=2; z=1,2,3,4}) { param( $key, $value ) 
        if (!$key) { return $true, $value, ($value*10) } 
        else { 
            if ($value -isnot [Array]) { $key, $value, "$key*10", ($value*10) }  else { $key, $value }
        }
    }

    Transform hashtable to multiply each key with 10 and add it as a new hashtable element.
    If array is encountered, each element is multiplied with 10 and added to the array besides original elements.

#>
function Edit-HashTable ($Hash, [ScriptBlock] $Action, [switch] $EnumerateArrays, [Parameter(DontShow = $true)] [string[]] $Parent ) {
    function is_hashtable { ($args[0] -is [HashTable]) -or ($args[0] -is [System.Collections.Specialized.OrderedDictionary]) }

    $res = if ($Hash -is [HashTable]) { @{} } else { [ordered]@{} }

    $Hash.Keys | % {
        $key = $_
        $val = $Hash.$key

        if ($val -ne $null) {
            if (is_hashtable $val) {
                $val = Edit-HashTable $val $Action ($Parent + $key)
            }

            if (($val -is [Array]) -and $EnumerateArrays) {
                $a=@()
                foreach ($item in $val) {
                    $b = & $Action $null $item "$($Parent).$($key)"
                    if ( !$b[0] ) { continue }
                    $a += $b[1..($b.Count)]                    
                }
                $val = $a
            }
        }
        $a = & $Action $key $val $parent
        for ($i=0; $i -lt $a.Count; $i+=2) {
            $k = $a[$i]; $v = $a[$i+1]
            if ($k) { $res.$k  = $v }
        }
    }
    $res
}