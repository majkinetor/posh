<#
.SYNOPSIS
    Creates a Symbolic link to a file or directory

.DESCRIPTION
    Creates a Symbolic link to a file or directory as an alternative to mklink.exe. 
    For details see http://goo.gl/zvFXon

.NOTES
    Author: Boe Prox
    Created: 15 Jul 2013
    Modified: Miodrag Milic

.EXAMPLE
    New-SymLink -Path "C:\users\admin\downloads" -SymName "C:\users\admin\desktop\downloads" -Directory

    Creates a symbolic link to downloads folder that resides on C:\users\admin\desktop.

.EXAMPLE
    New-SymLink -Path ..\document.txt -SymName "SomeDocument" -File

    Creates a symbolic link to "document.txt" in the parent folder to a file "SomeDocument" under the current directory.
#>
function New-SymLink {
    [cmdletbinding(
        DefaultParameterSetName = 'Directory',
        SupportsShouldProcess=$True
    )]
    Param (
        # Name of the path that you will reference with a symbolic link.
        [parameter(Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory=$True)]
        [ValidateScript({ if (Test-Path $_) {$true} else { throw "`'$_`' doesn't exist!" } })]
        [string]$Path,

        <#
          Name of the symbolic link to create. Can be a full path/unc or just the name.
          If only a name is given, the symbolic link will be created on the current directory that the
          function is being run on.
        #>
        [string]$SymName,

        # Create a file symbolic link
        [parameter(Position=2, ParameterSetName='File')]
        [switch]$File,

        # Create a directory symbolic link
        [parameter(Position=2, ParameterSetName='Directory')]
        [switch]$Directory,

        # Overwrite existing files
        [switch]$Force
    )
    Begin {
        Try {
            $null = [mklink.symlink]
        } Catch {
            Add-Type @"
            using System;
            using System.Runtime.InteropServices;

            namespace mklink
            {
                public class symlink
                {
                    [DllImport("kernel32.dll")]
                    public static extern bool CreateSymbolicLink(string lpSymlinkFileName, string lpTargetFileName, int dwFlags);

                    [DllImport("kernel32.dll")]
                    public static extern uint GetLastError();
                }
            }
"@
        }
    }
    Process {
        #Assume target Symlink is on current directory if not giving full path or UNC
        If ($SymName -notmatch "^(?:[a-z]:\\)|(?:\\\\\w+\\[a-z]\$)") {
            $SymName = "{0}\{1}" -f $pwd,$SymName
        }
        $Flag = @{
            File = 0
            Directory = 1
        }
        If ($PScmdlet.ShouldProcess($Path,'Create Symbolic Link')) {
            if ($Force -and (Test-Path $SymName)) {
                Write-Verbose "Removing existing destination $($PScmdlet.ParameterSetName)"
                rm $SymName -r -force -ea ignore
            }
            $return = [mklink.symlink]::CreateSymbolicLink($SymName, $Path, $Flag[$PScmdlet.ParameterSetName])
            If ($return) {
                $object = New-Object PSObject -Property @{
                    SymLink = $SymName
                    Target = $Path
                    Type = $PScmdlet.ParameterSetName
                }
                $object.pstypenames.insert(0,'System.File.SymbolicLink')
                $object
            } Else {
                $err = [mklink.symlink]::GetLastError()
                Throw (Get-ErrorMessage $err)
            }
        }
    }
 }

function Get-ErrorMessage {
[OutputType('System.String')]
[CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ErrorCode
    )
    $signature = @'
        [DllImport("kernel32.dll", SetLastError=true)]
        public static extern uint FormatMessage(
            uint dwFlags,
            IntPtr lpSource,
            int dwMessageId,
            uint dwLanguageId,
            ref IntPtr lpBuffer,
            uint nSize,
            IntPtr Arguments
        );
        [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Auto)]
        public static extern IntPtr LoadLibrary(
            string lpFileName
        );
        [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Auto)]
        public static extern bool FreeLibrary(
            IntPtr hModule
        );
        [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Auto)]
        public static extern IntPtr LocalFree(
            IntPtr hMem
        );
'@

    try {Add-Type -MemberDefinition $signature -Name Kernel32 -Namespace PKI}
    catch {Write-Warning $Error[0].Exception.Message; return}
    $StartBase = 12000
    $EndBase = 12176
    $ErrorHex = "{0:x8}" -f $ErrorCode
    $HighBytes = iex 0x$($ErrorHex.Substring(0,4))
    $LowBytes = iex 0x$($ErrorHex.Substring(4,4))
    $lpMsgBuf = [IntPtr]::Zero
    if ($LowBytes -gt $StartBase -and $LowBytes -lt $EndBase) {
        $hModule = [PKI.Kernel32]::LoadLibrary("wininet.dll")
        $dwChars = [PKI.Kernel32]::FormatMessage(0xb00,$hModule,$LowBytes,0,[ref]$lpMsgBuf,0,[IntPtr]::Zero)
        [void][PKI.Kernel32]::FreeLibrary($hModule)
    } else {$dwChars = [PKI.Kernel32]::FormatMessage(0x1300,[IntPtr]::Zero,$ErrorCode,0,[ref]$lpMsgBuf,0,[IntPtr]::Zero)}

    if ($dwChars -ne 0) {
        ([Runtime.InteropServices.Marshal]::PtrToStringAnsi($lpMsgBuf)).Trim()
        [void][PKI.Kernel32]::LocalFree($lpMsgBuf)
    } else {
        Write-Error -Category ObjectNotFound `
        -ErrorId "ElementNotFoundException" `
        -Message "No error messages are assoicated with error code: 0x$ErrorHex ($ErrorCode). Operation failed."
    }
}

#Export-ModuleMember -Function New-Symlink
Set-Alias ln New-Symlink
