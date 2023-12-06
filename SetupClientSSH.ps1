# Check if the private key file path is provided as an environment variable
if (-not $env:SSH_PRIVATE_KEY_PATH) {
    Write-Host "Please set the environment variable SSH_PRIVATE_KEY_PATH with the path to the private key file."
    return  # Use 'return' to exit without closing the terminal
}


Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# By default the ssh-agent service is disabled. Configure it to start automatically.
# Make sure you're running as an Administrator.
Get-Service ssh-agent | Set-Service -StartupType Automatic

# Start the service
Start-Service ssh-agent

# This should return a status of Running
Get-Service ssh-agent

# Read the private key from the file
$privateKeyPath = $env:SSH_PRIVATE_KEY_PATH
$privateKey = Get-Content -Raw $privateKeyPath

# Specify the destination directory for the private key
$sshDirectory = "$env:USERPROFILE\.ssh"
$idEd25519Path = Join-Path $sshDirectory "id_ed25519"

# Create the .ssh directory if it doesn't exist
if (-not (Test-Path $sshDirectory -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $sshDirectory
}

# Copy the private key file to the destination
Set-Content -Path $idEd25519Path -Value $privateKey -Force

ssh-add $idEd25519Path

Remove-Item -Path Env:\SSH_PRIVATE_KEY_PATH

Write-Host "Private key added to ssh-agent successfully."
