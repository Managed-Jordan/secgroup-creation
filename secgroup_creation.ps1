#creates the secgroup user group
"Creating the secgroup user group..."
net localgroup secgroup /add

#sets PowerShell to use TLS 1.2 connection
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#downloads and places the secgroup batch file
"downloading batch file to c:\netstrap\secgroup.bat..."
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Managed-Jordan/secgroup-creation/main/secgroup.txt' -OutFile 'C:\NetStrap\secgroup.bat'

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

#created a scheduled task to update the user list nightly
" "
"Creating scheduled task in Windows..."
$action = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument C:\NetStrap\secgroup.bat
$trigger = New-ScheduledTaskTrigger -Daily -At 4am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Daily Secgroup Update" -Description "Created by Managed.com"

" "
"Done! Please set up the scheduled task in Plesk and change ownership of cmd.exe and powershell.exe back to NT Service\TrustedInstaller"
