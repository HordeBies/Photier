# Photier

# Server
- Run the following command in an elevated(admin) powershell terminal on server machine:
```powershell
# Define the URL of the script and the local file path to save it to
$scriptUrl = "https://raw.githubusercontent.com/HordeBies/Photier/main/SetupServerSSH.ps1"
$tempFilePath = "$env:TEMP\SetupServerSSH.ps1"

# Download the script to the specified file path
Invoke-WebRequest -Uri $scriptUrl -OutFile $tempFilePath

# Define the public key as a parameter (replace with your actual public key or file path)
$pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHehF/C0gLsE+K8wsy/vG8Oc3OfY63mP+0QplxQ7Qa7RV95Bmlxhcp0b0BfRRdVHojkD9SSQt4M2MhV3Zi5kFVmw6Fa4yg0/VhaPG79UuWIEzuGxDlCawN0nXR/krw7FAtvO1TJDOVYObnEb/uH0lPs4+WMXfSsOZw1jFFqwaME9UwqTGiiHoRITD0Izs/KN3RqktwVhrLjXeMfcexSaw6vMWI5UNZ8t8KOXjBf+oH3rA7XsVfJ7Ef255P1Ad6RFpmtJyAhrYKhCQAJZHc1+lF2gI9kJ6k940eCy1V3PlzOn2j+AtrmV/4jLjXp1aPrnmwPhMXghtjapPNmm2xHgu8u1lO1MNQLfbMteYMEwu6q2Gt+XXCSfsvlE0CrtSCyK9vrCR7p8lW4KAWWrHNzitCDxDMyPuOWtlAfhafNTMmzPnbNrpKavclwsgZmpQ8hjErR/PJcksVpgtnz+jctYpRmy1D/fM1q2xMFPS9fxqqv7JLYG9ZcQ0DUtOLQ24CxYc= roysi@LAPTOP-FF6CL2LT"

# Execute the script with the public key parameter
. powershell -ExecutionPolicy Bypass -File $tempFilePath -pubkey $pubkey
```

# Client
1. Get the private key file from admin, download and get the path to the file (script will copy the key into a more secure location then you can delete the old file so dont worry about location).
2. Run the following command in an elevated(admin) powershell terminal on client machine:
```powershell
$env:SSH_PRIVATE_KEY_PATH = "{PATH_TO_PRIVATE_KEY}" # i.e. "D:\Downloads\PrivateKey"
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/HordeBies/Photier/main/SetupClientSSH.ps1").Content
```
