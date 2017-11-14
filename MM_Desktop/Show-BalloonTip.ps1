<#
.SYNOPSIS
    Show balloon tooltip

.DESCRIPTION
    Show balloon tooltip from system tray

.EXAMPLE
    Show-BalloonTip -Title Website -MessageType Info -Message 'Build OK!'
#>
function Show-BalloonTip {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$Title,
        
        [ValidateSet("Info","Warning","Error")]
        [string]$MessageType = "Info",

        [parameter(Mandatory=$true)]
        [string]$Message
    )

    [system.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
    $balloon = New-Object System.Windows.Forms.NotifyIcon
    $path = Get-Process -id $pid | Select-Object -ExpandProperty Path
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $balloon.Icon = $icon
    $balloon.BalloonTipIcon = $MessageType
    $balloon.BalloonTipText = $Message
    $balloon.BalloonTipTitle = $Title
    $balloon.Visible = $true
    $balloon.ShowBalloonTip(0)
    $balloon.Dispose()
}
