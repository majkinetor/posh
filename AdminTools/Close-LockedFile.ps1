<#
    Last Change: 10-Jun-2015.
    Modified: M. Milic <miodrag.milic@gmail.com>

.SYNOPSIS
    Close file locked by the application
.NOTE
    Original: http://stackoverflow.com/a/30744517/82660
#>
function Close-LockedFile {
Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String[]]$Filename
)
    Begin {
        $HandleApp = 'handle.exe'
        If(!(gcm $HandleApp)){
            Write-Error "Handle.exe not found at PATH.`nSee https://technet.microsoft.com/en-gb/sysinternals/bb896655.aspx"
            break
        }
    }
    Process {
        $HandleOut = Invoke-Expression ( $HandleApp +'/accepteula ' + $Filename )
        $Locks = $HandleOut | ? {$_ -match "(.+?)\s+pid: (\d+?)\s+type: File\s+(\w+?): (.+)\s*$"} | % {
            [PSCustomObject]@{
                AppName    = $Matches[1]
                PID        = $Matches[2]
                FileHandle = $Matches[3]
                FilePath   = $Matches[4]
            }
        }
        ForEach($Lock in $Locks){
            Invoke-Expression ($HandleApp + " -p " + $Lock.PID + " -c " + $Lock.FileHandle + " -y") | Out-Null
            if ( ! $LastexitCode ) { "Successfully closed " + $Lock.AppName + "'s lock on " + $Lock.FilePath}
        }
    }
}
