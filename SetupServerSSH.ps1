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
$authorizedKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrnRlRWlYJAjFEoIi2iG8eMDW9m9jUUrjyKst4WPj+g azureuser@DESKTOP-0UBG7UO"
Set-Content -Force -Path $env:ProgramData\ssh\administrators_authorized_keys -Value $authorizedKey ;icacls.exe ""$env:ProgramData\ssh\administrators_authorized_keys"" /inheritance:r /grant ""Administrators:F"" /grant ""SYSTEM:F""

# Restart SSH service to apply config changes
net stop sshd
net start sshd

# Install WinGet
(New-Object System.Net.WebClient).DownloadFile("https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx", (Join-Path -Path (Get-Location) -ChildPath "Microsoft.VCLibs.x64.14.00.Desktop.appx"))
(New-Object System.Net.WebClient).DownloadFile("https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx", (Join-Path -Path (Get-Location) -ChildPath "Microsoft.UI.Xaml.2.7.x64.appx"))
(New-Object System.Net.WebClient).DownloadFile("https://github.com/microsoft/winget-cli/releases/download/v1.7.3172-preview/b6e881d14bc943268a82d474bf7d15af_License1.xml", (Join-Path -Path (Get-Location) -ChildPath "b6e881d14bc943268a82d474bf7d15af_License1.xml"))
(New-Object System.Net.WebClient).DownloadFile("https://github.com/microsoft/winget-cli/releases/download/v1.7.3172-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle", (Join-Path -Path (Get-Location) -ChildPath "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"))

Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.UI.Xaml.2.7.x64.appx
Add-AppxProvisionedPackage -Online -PackagePath Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -LicensePath b6e881d14bc943268a82d474bf7d15af_License1.xml
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe

winget list --accept-source-agreements
