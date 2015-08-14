# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 24-Mar-2015.

<#
.SYNOPSIS
    Check SVN path for changes since last run of the command and do actions if needed.

.DESCRIPTION
    Check SVN path for changes and do actions if needed. Actions are scriptblocks which take one
    parameter - revision of the change. The function keeps the repository status in the file 'status'.

.EXAMPLE
   SVN-OnChange @{ trunk = { Trunk changed, revision $args[0] }; 'branches/next'= {Next changed} }

   Check 'trunk' and 'branches/next' for changes since last run and display message when it happens.
#>

function SVN-OnChange {
    [CmdletBinding()]
    param(
        # Hashtable containing repository paths to check (keys) and actions to take (values)
        [Parameter(Mandatory=$true, ValueFromPipeLine=$true)]
        [ValidateNotNullOrEmpty()]
        [HashTable]$Actions
    )

    $ErrorActionPreference = 'stop'

    function get-revision() {
        $rev = svn info 2>&1 | sls '^Last Changed Rev:' | out-string
        $rev = $rev -split ':'
        $rev[1].Trim()
    }

    function if-changed([string]$SVNPath, [Scriptblock]$Script) {
        Write-Verbose "Checking for changes: $SVNPath"
        pushd $SVNPath
        $r = get-revision

        if ($r -gt $status[$SVNPath]) {
            Write-Verbose "|- '$SVNPath' changed, revision $r"
            try { & $Script $r } catch { popd; throw }
        }
        else { Write-Verbose "|- '$SVNPath' is up to date at revision $r" }
        $status[$SVNPath] = $r
        popd
    }


    Write-Verbose "Updating repository"
    svn update | out-null

    Write-Verbose "Reading status file"
    if (Test-Path status) { $status = Import-Clixml status } else { Write-Verbose "|- No status found, creating one."; $status=@{} }

    $Actions.Keys | % { if-changed $_ $Actions[$_] }

    $status | Export-CliXML status
    Write-Verbose "Done"
}
