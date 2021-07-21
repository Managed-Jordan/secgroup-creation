#sets PowerShell to use TLS 1.2 connection
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#downloads and places the secgroup batch file
" "
"updating c:\netstrap\secgroup.bat..."
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Managed-Jordan/secgroup-creation/main/secgroup.txt' -OutFile 'C:\NetStrap\secgroup.bat'

#runs updated file
" "
"Running secgroup.bat..."
C:\NetStrap\secgroup.bat

#sleep 2 seconds
" "
"Done!"
Start-Sleep -s 2
