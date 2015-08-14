# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 03-Mar-2015.
# Adapted from:  http://goo.gl/xvHcSE

#requires -version 1.0

<#
.SYNOPSIS
    This function are used to pin and unpin programs from the taskbar and Start-menu.

.EXAMPLE
    Set-PinnedApplication -Action PinToTaskbar -FilePath "C:\WINDOWS\system32\notepad.exe"

.EXAMPLE
    gcm notepad,explorer | Set-PinnedApplication -Action PinToTaskbar -Verbose

.NOTES
    Tested on platforms: Windows 7, Windows Server 2008 R2, Windows 8.1, Windows 10
#>
function Set-PinnedApplication
{
    [CmdletBinding()]
    param(
        # Action to take: PinToTaskbar (default), PinToStartMenu, UnPinFromTaskbar, UnPinFromStartMenu
        [ValidateSet('PinToTaskbar', 'PinToStartMenu', 'UnPinFromTaskbar', 'UnPinFromStartMenu')]
        [string]$Action='PinToTaskbar',

        # Path to executable for the action
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFrompiPelinebyPropertyName=$true)]
        [Alias('Path')]
        [string[]]$FilePath
    )

    begin
    {
        function InvokeVerb ([string]$FilePath, $verb)
        {
            $verb     = $verb.Replace("&","")
            $path     = split-path $FilePath
            $shell    = new-object -com "Shell.Application"
            $folder   = $shell.Namespace($path)
            $item     = $folder.Parsename((split-path $FilePath -leaf))
            $itemVerb = $item.Verbs() | ? {$_.Name.Replace("&","") -eq $verb}
            if($itemVerb -eq $null){ throw "Verb $verb not found." } else { $itemVerb.DoIt() }
        }

        function GetVerb ($verbId)
        {
            try {
                $t = [type]"CosmosKey.Util.MuiHelper"
            } catch {
                $def = @"

                [DllImport("user32.dll")]
                public static extern int LoadString(IntPtr h,uint id, System.Text.StringBuilder sb,int maxBuffer);

                [DllImport("kernel32.dll")]
                public static extern IntPtr LoadLibrary(string s);
"@
                Add-Type -MemberDefinition $def -name MuiHelper -namespace CosmosKey.Util
            }
            if($global:CosmosKey_Utils_MuiHelper_Shell32 -eq $null){
                $global:CosmosKey_Utils_MuiHelper_Shell32 = [CosmosKey.Util.MuiHelper]::LoadLibrary("shell32.dll")
            }

            $maxVerbLength = 255
            $verbBuilder   = new-object Text.StringBuilder "",$maxVerbLength
            [void][CosmosKey.Util.MuiHelper]::LoadString($CosmosKey_Utils_MuiHelper_Shell32, $verbId, $verbBuilder, $maxVerbLength)
            return $verbBuilder.ToString()
        }

        $verbs = @{
            "PintoStartMenu"     = 5381
            "UnpinfromStartMenu" = 5382
            "PintoTaskbar"       = 5386
            "UnpinfromTaskbar"   = 5387
        }
    }
    process {
       $FilePath | % {
            if (!(Test-Path $_)) {Write-Verbose "Path doesn't exist: $_"; return}
            Write-Verbose "$Action for $_"
            InvokeVerb -FilePath $_ -Verb $(GetVerb -VerbId $verbs.$action)
        }
    }
}
