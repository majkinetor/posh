<#
.SYNOPSIS
    Write nested HashTable to output

.DESCRIPTION
    The usual HashTable output function do not display nested hashtables.
#>
function Write-HashTable { 
    param(
        # ([ordered]) Hashtable to display
        $HashTable,

        # List of keys to include (only first level)
        [string[]] $Include,

        # List of keys to exclude from all nested HashTables
        [string[]] $Exclude,

        # List of keys to hide - values are replaced with '*****'
        [string[]] $Hide,

        [Parameter(DontShow = $true)]
        [int] $Indent
    ) 

    $HashTable.Keys | % { $max_len=0 } { $l = $_.ToString().Length; if ($l -gt $max_len) { $max_len = $l } }
    foreach ($kv in $HashTable.GetEnumerator()) {
        if ($kv.Key -in $Exclude) { continue }
        if ($Include -and ($kv.Key -notin $Include)) { continue }

        $is_HashTable = ($kv.Value -is [HashTable]) -or ($kv.Value -is [System.Collections.Specialized.OrderedDictionary])
        if ($is_HashTable) { 
            $val = Write-HashTable $kv.Value -Hide $Hide -Include $null -Exclude $Exclude -Indent ($Indent + 2) 
        } 
        elseif ($kv.Value -is [Array] ) {
            $v = $kv.Value[0..3] -join ', '
            $v += if ($kv.Value.Count -gt 5) { '...' }
            $val = "{" + $v + "}"
        }
        else { 
            $val = if ($kv.Value) { $kv.Value.ToString() } else { '' }
            if ($val.IndexOf("`n") -ne -1) {
                $val = $val -split "`n"
                $val = $val[0] + ($val[1..5] | % { "`n" + ' '*($max_len+3+$Indent) + $_})
            }
        }            
        
        if ($kv.Key -in $Hide) { 
            $rval = '*****'
            $val = if ($is_HashTable) { $val -replace '(?<=: ).+', $rval }  else  { $rval }
        }
        $key = ' '*$Indent + $kv.Key.ToString().PadRight($max_len)
        if ($is_HashTable) { $key; $val } else { $key + ' : '  + $val }
    }
}

# $x = [ordered]@{
#     x=1
#     y=2
#     z=@{ x=1; p = 1}
# }

# Write-HashTable $x -Include 'z'