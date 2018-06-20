function ConvertTo-Base64String( [string] $s)   { [Convert]::ToBase64String( [System.Text.Encoding]::Utf8.GetBytes($s)) }
function ConvertFrom-Base64String( [string] $s) { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($s))}

<#
.SYNOPSIS
    Convert from / to Base64 string

.EXAMPLE
    'foo bar' | b64 | % { Write-Host $_; $_ } | b64 -From

    Encode string 'foo bar' to Base64 form, dispaly it, and decode it.

#>
function b64 ( [Parameter(ValueFromPipeline=$true)] [string] $s, [switch]$From) { if ($From) { ConvertFrom-Base64String $s } else { ConvertTo-Base64String $s} }