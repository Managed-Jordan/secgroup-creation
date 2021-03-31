#creates the secgroup user group
"Creating the secgroup user group..."
net localgroup secgroup /add

#downloads and places the secgroup batch file
"downloading batch file to c:\secgroup.bat..."
Invoke-WebRequest -Uri 'https://requiemsecurity.com/wp-content/uploads/2021/03/secgroup.txt' -OutFile 'c:\secgroup.bat'

#changes ownership of cmd.exe to the administrators group
"Changing ownership of cmd.exe to administrators group..."
TAKEOWN /F "C:\Windows\System32\cmd.exe" /A

#changes ownership of powershell.exe to the administrators group
"Changing ownership of powershell.exe to administrators group..."
TAKEOWN /F "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" /A

#denies read and write access for the secgroup user group
" "
"Denying read and write permissions for cmd.exe for the secgroup user group..."
icacls "C:\Windows\System32\cmd.exe" /deny "secgroup:RX"

#denies read and write access for the secgroup user group
" "
"Denying read and write permissions for powershell.exe for the secgroup user group..."
icacls "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" /deny "secgroup:RX"

" "
"Done! Please set up the scheduled task in Plesk and change ownership of cmd.exe and powershell.exe back to NT Service\TrustedInstaller"
