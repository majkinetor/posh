# Adapted from:  http://goo.gl/xvHcSE

function Set-PinnedApplication
{
<#
.SYNOPSIS
    This function are used to pin and unpin programs from the taskbar and Start-menu.
.EXAMPLE
    Set-PinnedApplication -Action PinToTaskbar -FilePath "C:\WINDOWS\system32\notepad.exe"
.NOTES
    Tested on platforms: Windows 7, Windows Server 2008 R2, Windows 8.1, Windows 10
#>
[CmdletBinding()]
    param(
        [ValidateSet('PinToTaskbar', 'PinToStartMenu', 'UnPinFromTaskbar', 'UnPinFromStartMenu')]
        [Parameter(Mandatory=$true)]
        [string]$Action,

        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFrompiPelinebyPropertyName=$true)]
        [Alias('Path')]
        [string]$FilePath
    )
    if(-not (test-path $FilePath)) { throw "FilePath does not exist." }

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

    InvokeVerb -FilePath $FilePath -Verb $(GetVerb -VerbId $verbs.$action)
}
