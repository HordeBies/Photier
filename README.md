# Photier

# Server
- Run the following command in an elevated(admin) powershell terminal on server machine:
```powershell
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/HordeBies/Photier/main/SetupServerSSH.ps1").Content
```

# Client
1. Get the private key file from admin, download and get the path to the file (script will copy the key into a more secure location then you can delete the old file so dont worry about location).
2. Run the following command in an elevated(admin) powershell terminal on client machine:
```powershell
$env:SSH_PRIVATE_KEY_PATH = "{PATH_TO_PRIVATE_KEY}" # i.e. "D:\Downloads\PrivateKey"
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/HordeBies/Photier/main/SetupClientSSH.ps1").Content
```
