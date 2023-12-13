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
#Requires -Modules 'NtObjectManager'
[CmdletBinding()]
Param(
    # None
)

# Download dependencies
$AppxDependencies = @(
    @{
        ShortName     = 'vclibs'
        QualifiedName = 'Microsoft.VCLibs.140.00_8wekyb3d8bbwe'
    },
    @{
        ShortName     = 'vclibsuwp'
        QualifiedName = 'Microsoft.VCLibs.140.00.UWPDesktop_8wekyb3d8bbwe'
    }
)
ForEach ($Dependency in $AppxDependencies) {
    $InvokeWebRequestSplat = @{
        Uri             = 'https://store.rg-adguard.net/api/GetFiles'
        Method          = 'POST'
        ContentType     = 'application/x-www-form-urlencoded'
        Body            = "type=PackageFamilyName&url=$($Dependency.QualifiedName)&ring=RP&lang=en-US"
        UseBasicParsing = $True
    }
    $InvokeWebRequestSplat = @{
        Uri     = ((Invoke-WebRequest @InvokeWebRequestSplat).Links | Where-Object {$_.OuterHTML -match '.appx' -and $_.outerHTML -match 'x64'}).href
        OutFile = "$env:temp/$($Dependency.ShortName).appx"
    }
    Invoke-WebRequest @InvokeWebRequestSplat
}
# Download latest release (along with license) from github
$InvokeRestMethodSplat = @{
    Uri    = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    Method = 'GET'
}
$LatestRelease = Invoke-RestMethod @InvokeRestMethodSplat
$InvokeWebRequestSplat = @{
    Uri     = ($LatestRelease.assets | Where-Object {$_.name -like '*.msixbundle'}).browser_download_url
    OutFile = "$env:temp\winget.msixbundle"
}
Invoke-WebRequest @InvokeWebRequestSplat
$InvokeWebRequestSplat = @{
    Uri     = ($LatestRelease.assets | Where-Object {$_.name -like '*license*.xml'}).browser_download_url
    OutFile = "$env:temp\wingetlicense.xml"
}
Invoke-WebRequest @InvokeWebRequestSplat

# Install dependencies
$AppxDependencies.ShortName | ForEach-Object {
    $AddAppxPackageSplat = @{
        Path = "$env:temp/$($_).appx"
    }
    Add-AppxPackage @AddAppxPackageSplat
}
# Install winget
$AddAppxProvisionedPackageSplat = @{
    Online = $True
    PackagePath = "$env:temp\winget.msixbundle"
    LicensePath = "$env:temp\wingetlicense.xml"
}
Add-AppxProvisionedPackage @AddAppxProvisionedPackageSplat

# Create reparse point
$SetExecutionAliasSplat = @{
    Path        = "$([System.Environment]::SystemDirectory)\winget.exe"
    PackageName = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe"
    EntryPoint  = "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe!winget"
    Target      = "$((Get-AppxPackage Microsoft.DesktopAppInstaller).InstallLocation)\AppInstallerCLI.exe"
    AppType     = 'Desktop'
    Version     = 3
}
Set-ExecutionAlias @SetExecutionAliasSplat
& explorer.exe "shell:appsFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe!winget"
winget list --accept-source-agreements
