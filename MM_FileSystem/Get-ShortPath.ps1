<#
.SYNOPSIS
    Get the short path (8.3) of the file path
.EXAMPLE
    ls $Env:ProgramFiles | Get-ShortPath
#>
function Get-ShortPath
{
    BEGIN { 
        $fso = New-Object -ComObject Scripting.FileSystemObject 
    }
    PROCESS {
        $f = $_
        if ($f.psiscontainer) { $fso.getfolder($f.fullname).ShortPath }
        else { $fso.getfile($f.fullname).ShortPath } 
    } 
}
