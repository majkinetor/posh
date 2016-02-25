# taken from: http://techibee.com/powershell/system-tray-pop-up-message-notifications-using-powershell/1865
# $ballon.Dispose at the end
function Show-BalloonTip {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$Title,
        [ValidateSet("Info","Warning","Error")]
        [string]$MessageType = "Info",
        [parameter(Mandatory=$true)]
        [string]$Message,
        [string]$Duration=10000
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
    $balloon.ShowBalloonTip($Duration)
    $ballon
}
