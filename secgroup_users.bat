net localgroup psacln | findstr "IWPD*" > C:\NetStrap\users.txt
FOR /F %%A in (C:\NetStrap\users.txt) DO net localgroup secgroup %%A /add
net stop W3SVC && net stop WAS
net start W3SVC
