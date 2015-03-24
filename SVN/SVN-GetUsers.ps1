
function SVN-GetUsers {
    [CmdletBinding()]
    param(
       [string] $Repository,
       [string[]] $Exclude
    )
    svn log $Repository | select-string "^r[0-9]" |
                % { $_.ToString().Split("|")[1] } | sort -Unique | % { $_.Trim() } | ? { $Exclude -notcontains $_ }
}
