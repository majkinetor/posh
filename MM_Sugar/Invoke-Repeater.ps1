# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 14-Aug-2015.

<#
.SYNOPSIS
    Invoke script multiple times

.EXAMPLE
   Invoke-Repeater { Remove-Item $dir } -Message "Removing files"

.EXAMPLE
   Invoke-Repeater { Remove-Item $dir } -Message "Removing files" -FailureScript { Write-Warning "Failed to remove, ignoring" }
#>
function Invoke-Repeater([ScriptBlock] $ScriptBlock, $Message, [int] $MaxCount=3, [int] $Sleep = 5, [ScriptBlock] $FailureScript )
{
    Write-Host $Message
    for ($i = 1; $i -le $MaxCount; $i++) {
        try {
            & $ScriptBlock
            break
        } catch {
            Write-Host "  failed executing script $i/$MaxCount"
            $errMessage = $_.Exception.Message -split "`n"
            $errMessage | % { Write-Host "    " $_ }

            if ($i -eq $MaxCount) { 
                if (!$FailureScript) { throw $_ } else {
                    & $FailureScript $_
                    break
                }
            }
            Write-Host "  trying again in $Sleep seconds`n"; Start-Sleep $Sleep
        }
    }
}
