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

# Create install directory
if (!(Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir | Out-Null }

# Download ZIP
$zipFile = "$env:TEMP\RunWithPower.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile

# Extract ZIP to temp folder first
$tempExtract = Join-Path $env:TEMP "RunWithPowerExtract"
if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
New-Item -ItemType Directory -Path $tempExtract | Out-Null

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $tempExtract)

# Move contents to installDir (flatten)
Get-ChildItem -Path $tempExtract -Recurse | ForEach-Object {
    $destination = Join-Path $installDir $_.Name
    if ($_.PSIsContainer) { 
        if (!(Test-Path $destination)) { New-Item -ItemType Directory -Path $destination | Out-Null } 
    } else { 
        Copy-Item $_.FullName $destination -Force
    }
}

# Clean up temp
Remove-Item $zipFile
Remove-Item $tempExtract -Recurse -Force

# Find the EXE
$exePath = Get-ChildItem -Path $installDir -Filter "*.exe" | Select-Object -First 1
if (-not $exePath) { Write-Host "Error: EXE not found!" -ForegroundColor Red; exit }

# Create Desktop shortcut
$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut($desktopShortcut)
$shortcut.TargetPath = $exePath.FullName
$shortcut.WorkingDirectory = $installDir
$shortcut.Save()

# Create Start Menu shortcut
if (!(Test-Path $startMenuDir)) { New-Item -ItemType Directory -Path $startMenuDir | Out-Null }
$startShortcut = $WshShell.CreateShortcut("$startMenuDir\RunWithPower3.0.lnk")
$startShortcut.TargetPath = $exePath.FullName
$startShortcut.WorkingDirectory = $installDir
$startShortcut.Save()

Write-Host "Installation complete! RunWithPower3.0 installed in Program Files with shortcuts."
