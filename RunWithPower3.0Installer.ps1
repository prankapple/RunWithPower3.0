# Check for admin and relaunch elevated if needed
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Not running as Administrator. Relaunching..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Variables
$zipUrl = "https://github.com/prankapple/RunWithPower3.0/releases/download/RunWithPower3.0/RunWithPower.zip"
$installDir = "$env:ProgramFiles\RunWithPower3.0"
$desktopShortcut = "$env:Public\Desktop\RunWithPower3.0.lnk"
$startMenuDir = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\RunWithPower3.0"
$exeName = "RunWithPower3.0.exe"

# Create install directory
if (!(Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir | Out-Null }

# Download ZIP
$zipFile = "$env:TEMP\RunWithPower.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile

# Extract ZIP (overwrite if exists)
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $installDir, $true)

# Remove ZIP
Remove-Item $zipFile

# Create Desktop shortcut for all users
$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut($desktopShortcut)
$shortcut.TargetPath = "$installDir\$exeName"
$shortcut.WorkingDirectory = $installDir
$shortcut.Save()

# Create Start Menu shortcut
if (!(Test-Path $startMenuDir)) { New-Item -ItemType Directory -Path $startMenuDir | Out-Null }
$startShortcut = $WshShell.CreateShortcut("$startMenuDir\RunWithPower3.0.lnk")
$startShortcut.TargetPath = "$installDir\$exeName"
$startShortcut.WorkingDirectory = $installDir
$startShortcut.Save()

Write-Host "Installation complete! RunWithPower3.0 installed in Program Files with shortcuts."
