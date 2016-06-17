<#
    Last Change: 27-Apr-2016.
    Author: M. Milic <miodrag.milic@gmail.com>

.SYNOPSIS
    Get Non-Interactive (NI) credentials
#>
function Get-NICredential([string]$Username, [string]$Password)
{
    $ss = New-Object SecureString
    $Password.ToCharArray() | % { $ss.AppendChar($_) }
    New-Object PSCredential -Argumentlist $Username, $ss
}
