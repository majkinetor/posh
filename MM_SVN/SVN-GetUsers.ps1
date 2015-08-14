# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 24-Mar-2015.

<#
.SYNOPSIS
    Get the array of SVN users
.EXAMPLES
    SVN-GetUsers 'http:\\svn\projectx' -Exclude 'VisualSVN Server','jenkins'

    Get the list of users but exclude application accounts.
#>
function SVN-GetUsers {
    [CmdletBinding()]
    param(
        # SVN Repository path
        [string] $Repository,
        # Names to exclude from the list
        [string[]] $Exclude
    )
    svn log $Repository | select-string "^r[0-9]" |
                % { $_.ToString().Split("|")[1] } | sort -Unique | % { $_.Trim() } | ? { $Exclude -notcontains $_ }
}
