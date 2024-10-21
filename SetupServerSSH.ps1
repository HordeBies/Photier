# Check if the public key argument is provided
param (
    [string]$pubkey
)

if (-not $pubkey) {
    Write-Host "Usage: ./script.ps1 <pubkey path/value>"
    exit
}

# Determine if the provided argument is a file path or a string
if (Test-Path $pubkey) {
    # If it's a valid file path, read the public key from the file
    $authorizedKey = Get-Content -Path $pubkey -Raw
} else {
    # Otherwise, treat it as a public key string
    $authorizedKey = $pubkey
}

Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}

# Configure PowerShell as default shell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

# Setup key based authentication
Set-Content -Force -Path $env:ProgramData\ssh\administrators_authorized_keys -Value $authorizedKey ;icacls.exe ""$env:ProgramData\ssh\administrators_authorized_keys"" /inheritance:r /grant ""Administrators:F"" /grant ""SYSTEM:F""

# Restart SSH service to apply config changes
net stop sshd
net start sshd

# Install WinGet
(New-Object System.Net.WebClient).DownloadFile("https://drive.google.com/uc?id=1qCGlzVaL8BMdFZN78GMgmQDByLt5AxtW", (Join-Path -Path (Get-Location) -ChildPath "Microsoft.VCLibs.x64.14.00.Desktop.appx"))
(New-Object System.Net.WebClient).DownloadFile("https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx", (Join-Path -Path (Get-Location) -ChildPath "Microsoft.UI.Xaml.2.8.x64.appx"))
(New-Object System.Net.WebClient).DownloadFile("https://drive.google.com/uc?id=10v7Sqpmtvk9Rqt2MffNPhYnvKdcr0nCy", (Join-Path -Path (Get-Location) -ChildPath "76fba573f02545629706ab99170237bc_License1.xml"))
(New-Object System.Net.WebClient).DownloadFile("https://github.com/microsoft/winget-cli/releases/download/v1.8.1911/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle", (Join-Path -Path (Get-Location) -ChildPath "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"))
Start-Sleep -Seconds 1.5
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx
Add-AppPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Add-AppxProvisionedPackage -Online -PackagePath .\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -LicensePath .\76fba573f02545629706ab99170237bc_License1.xml

# Accept WinGet source agreements
winget list --accept-source-agreements
