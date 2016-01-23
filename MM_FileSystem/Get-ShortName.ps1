<#
    Last Change: 23-Jan-2016.
    Modified: M. Milic <miodrag.milic@gmail.com>

.SYNOPSIS
    Get the short name (8.3) of the file path
#>
function Get-ShortName
{
    begin {

        $code = @'
            [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError=true)]
            public static extern uint GetShortPathName(string longPath,
            StringBuilder shortPath,uint bufferSize);
'@
            $API = Add-Type -MemberDefinition $code -Name Path -UsingNamespace System.Text -PassThru
    }

    process {
        $shortBuffer = New-Object Text.StringBuilder ($_.FullName.Length * 2 )
        $rv = $API::GetShortPathName( $_.Fullname, $shortBuffer, $shortBuffer.Capacity )
        if ($rv -eq 0) { Write-Warning "Can't get short name for the file: $_"; return }
        $shortBuffer.ToString()
    }
}
