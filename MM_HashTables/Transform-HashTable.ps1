# Transform hashtable to another hashtable
#   Action params: key, value, parent (if value is array, action will be called with $null key)
#   Action output: new key, new_value ($null as a key deletes key on the output in both hash and array)
function Transform-HashTable ([HashTable]$Hash, [ScriptBlock] $Action, [string]$Parent ) {
    $res = @{}

    $Hash.Keys | % {
        $key = $_
        $val = $Hash.$key

        if ($val -ne $null) {
            if ($val.GetType() -eq [HashTable]) {
                $h = transform_hash $val $Action "$($Parent).$($key)"
                $res.$key = $h
                return
            }
            if ($val.GetType() -eq [Object[]]) {
                $a =@()
                $val | % {
                    $k,$v = & $Action $null $_ "$($Parent).$($key)"
                    if ($k){ $a+=$v }
                }
                $res.$key = $a
                return
            }
        }
        $k,$v = & $Action $key $val $parent
        if ($k){ $res.$k  = $v }
    }
    $res
}

