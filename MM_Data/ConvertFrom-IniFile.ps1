<#
    Author: M. Milic <miodrag.milic@gmail.com>

.SYNOPSIS
    Convert ini file to ordered HashTable
#>
function ConvertFrom-IniFile ($file) {
    $ini = [ordered]@{}
  
    switch -regex -file $file {
      "^\s*\[(.+)\]\s*$" {
        $section = $matches[1].Trim()
        $ini.$section = [ordered]@{}
      }
      "^\s*(.+?)\s*=(.*)" {
        $name,$value = $matches[1..2]
        if ($name.StartsWith(";")) { continue }  # skip comments
        $ini.$section.$name = $value
      }
    }
    $ini
}