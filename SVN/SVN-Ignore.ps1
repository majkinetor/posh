# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 20-Feb-2015.

<#
.SYNOPSIS
    Get, add or remove files to the svn ignore list for the current directory.

.PARAMETER Remove
    Set to remove files instead of adding them.

.EXAMPLE
    svn-ignore file1 file2 glob? *.log
#>
function svn-ignore([switch]$Remove)
{
    $OFS="`n"
    $ignored = svn propget svn:ignore

    if ($args.Length -ne 0) {
        if (!$Remove)
        {
            $files = $args -join "`n"
            $files = $files | ? {$ignored -notcontains $_}
            $ignored = "${ignored}${files}".Trim()
        } else {
            $args | % { $ignored = $ignored -replace [Regex]::Escape($_),'' }
            $ignored = $ignored -split "`n" | ? { $_.Trim() -ne '' }
        }

        svn propset svn:ignore "$ignored" .
    }

    $out = ($ignored -split "`n")
    "Currently ignored in this dir ($($out.Length)):`n`n"
    $out
}
