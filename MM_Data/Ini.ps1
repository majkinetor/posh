<#
    Author: M. Milic <miodrag.milic@gmail.com>
    
    Quick and dirty Ini functions
#>

<#
.SYNOPSIS
    Convert ini string to ordered HashTable
#>
function ConvertFrom-Ini{
    param(
        # Array of strings representing ini content
        [Parameter(ValueFromPipeline=$true)]
        [string[]] $InputObject,

        # Trim key and section values
        [switch] $Trim
    )

    $ini = [ordered]@{}  
    switch -Regex ($InputObject -split "`r`n" ) {
      "^\s*\[(.+)\]\s*$" {
        $section = $matches[1]; if ($Trim) { $section = $section.Trim() }
        $ini.$section = [ordered]@{}
      }
      "^\s*(.+?)\s*=(.*)" {
        $key, $value = $matches[1..2]; if ($Trim) { $value = $value.Trim() }
        if ($key.StartsWith(";")) { continue }     # skip comments
        $ini.$section.$key = $value; 
      }
    }
    $ini
}

<#
.SYNOPSIS
    Set ini value 

.DESCRIPTION
    Set ini value in memory using regular expression replace.
    This is not fast, but ini files are usually very small and this keeps original formating, comments etc.
#>
function Set-IniValue {
    param(
        # Ini string
        [Parameter(ValueFromPipeline=$true)]
        [string] $InputObject,
        
        [Parameter(Mandatory=$true)]
        [string] $Section,

        [Parameter(Mandatory=$true)]
        [string] $Key,

        # Key value; if null, key will be deleted
        $Value = $null
    ) 
    
    $remove = $Value -eq $null
    $line = if ($remove) {''} else { "$Key=$Value" }

    $sectionRe = '(?<=(?:\s*\n)+)\[\s*(?<Section>.+?)\s*\]\s*\n(?<Keys>(?:.|\n)*?)(?=(?:\s*\n)*\[)'
    $m = "`n$ini`n[" | sls -AllMatches $sectionRe
    $matchSection = $m.Matches | ? { $_.Groups['Section'].Value -eq $Section }
    if (!$matchSection) { return $( if ($remove) {} else { "$ini`n[$Section]`n$line" } ) }
    
    $matchKeys = $matchSection.Groups['Keys']
    $keys = $matchKeys.Value
    if ($keys -and ($m = "`n$keys`n" | sls "\s*\n$Key\s*=.+(?=\n)")) {
        $idxStart = $matchKeys.Index + $m.Matches[0].Index - 2
        $idxEnd   = $idxStart + $m.Matches[0].Length
        if (!$remove) { $line = "`n$line"}
        $ini = $ini.Substring(0, $idxStart) + $line + $ini.Substring($idxEnd)
    } else {
        if ($remove) { return }
        $ini = $ini -replace "`n\s*\[\s*$Section\s*\]\s*", "`$0`n$line`n"
    }
    $ini 
}

$ini = @"
[S1]
foo = boo
faa=baaa   

[S2]
foo = boo
saa saa = b1 c2  d3
p=l
[Empty]
;Empty with comment
[Empty2]

[Empty3]

[S3]

; Some comment here
foo= boo

; More comments
sa = ba

[Meh]
"@

# $ini = gc "$Env:AppData\Ghisler\wincmd.ini" -Encoding UTF8 -Raw
#$ini = Set-IniValue $ini FileSystemPlugins Uninstaller64 meh
#$ini = Set-IniValue $ini FileSystemPlugins64 Uninstaller64 1
#$ini | Out-File temp.ini