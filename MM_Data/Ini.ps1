<#
    Author: M. Milic <miodrag.milic@gmail.com>

.SYNOPSIS
    Convert ini string to ordered HashTable

.OUTPUTS
    [ordered]@{}
#>
function ConvertFrom-Ini{
    param(
        # Array of strings representing ini content
        [Parameter(ValueFromPipeline=$true)]
        [string[]] $InputObject
    )

    $res = [ordered]@{}
    
    switch -Regex ($InputObject) {
      "^\s*\[(.+)\]\s*$" {
        $section = $matches[1].Trim()
        $ini.$section = [ordered]@{}
      }
      "^\s*(.+?)\s*=(.*)" {
        $name, $value = $matches[1..2]
        if ($name.StartsWith(";")) { continue }     # skip comments
        $ini.$section.$name = $value
      }
    }
    $res
}