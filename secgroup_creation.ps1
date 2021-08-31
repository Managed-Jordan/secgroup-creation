#creates the secgroup user group
"Creating the secgroup user group..."
net localgroup secgroup /add

#sets PowerShell to use TLS 1.2 connection
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#downloads and places the secgroup batch file
"downloading batch file to c:\netstrap\secgroup.bat..."
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Managed-Jordan/secgroup-creation/main/secgroup_update.ps1' -OutFile 'C:\NetStrap\secgroup_update.ps1'

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

#changes ownership of cmd.exe and powershell.exe back
" "
"Changing ownership of cmd.exe and powershell.exe back to NT Service\TrustedInstaller..."
$PATHNAME1 = "C:\Windows\System32\cmd.exe"
$PATHNAME2 = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

Function Enable-Privilege 
{
 param([ValidateSet("SeAssignPrimaryTokenPrivilege", "SeAuditPrivilege", "SeBackupPrivilege",
   "SeChangeNotifyPrivilege", "SeCreateGlobalPrivilege", "SeCreatePagefilePrivilege",
   "SeCreatePermanentPrivilege", "SeCreateSymbolicLinkPrivilege", "SeCreateTokenPrivilege",
   "SeDebugPrivilege", "SeEnableDelegationPrivilege", "SeImpersonatePrivilege", "SeIncreaseBasePriorityPrivilege",
   "SeIncreaseQuotaPrivilege", "SeIncreaseWorkingSetPrivilege", "SeLoadDriverPrivilege",
   "SeLockMemoryPrivilege", "SeMachineAccountPrivilege", "SeManageVolumePrivilege",
   "SeProfileSingleProcessPrivilege", "SeRelabelPrivilege", "SeRemoteShutdownPrivilege",
   "SeRestorePrivilege", "SeSecurityPrivilege", "SeShutdownPrivilege", "SeSyncAgentPrivilege",
   "SeSystemEnvironmentPrivilege", "SeSystemProfilePrivilege", "SeSystemtimePrivilege",
   "SeTakeOwnershipPrivilege", "SeTcbPrivilege", "SeTimeZonePrivilege", "SeTrustedCredManAccessPrivilege",
   "SeUndockPrivilege", "SeUnsolicitedInputPrivilege")]$Privilege,
  $ProcessId = $pid,
  [Switch]$Disable)

   $Definition = @'
 using System;
 using System.Runtime.InteropServices;

 public class AdjPriv
 {
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,
   ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);

  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
  [DllImport("advapi32.dll", SetLastError = true)]
  internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct TokPriv1Luid
  {
   public int Count;
   public long Luid;
   public int Attr;
  }

  internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
  internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
  internal const int TOKEN_QUERY = 0x00000008;
  internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
  public static bool EnablePrivilege(long processHandle, string privilege, bool disable)
  {
   bool retVal;
   TokPriv1Luid tp;
   IntPtr hproc = new IntPtr(processHandle);
   IntPtr htok = IntPtr.Zero;
   retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
   tp.Count = 1;
   tp.Luid = 0;
   if(disable)
   {
    tp.Attr = SE_PRIVILEGE_DISABLED;
   }
   else
   {
    tp.Attr = SE_PRIVILEGE_ENABLED;
   }
   retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
   retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
   return retVal;
  }
 }
'@


 $ProcessHandle = (Get-Process -id $ProcessId).Handle
 $type = Add-Type $definition -PassThru
 $type[0]::EnablePrivilege($processHandle, $Privilege, $Disable)

}


[System.Security.Principal.NTAccount]$TrustedInstaller = "NT SERVICE\TrustedInstaller"
$ACL1 = Get-Acl $PATHNAME1
$ACL1.SetOwner($TrustedInstaller)
Enable-Privilege SeRestorePrivilege  
Set-Acl -Path $PATHNAME1 -AclObject $ACL1

$ACL2 = Get-Acl $PATHNAME2
$ACL2.SetOwner($TrustedInstaller)
Enable-Privilege SeRestorePrivilege  
Set-Acl -Path $PATHNAME2 -AclObject $ACL2

#created a scheduled task to update the user list nightly
" "
"Creating scheduled task in Windows..."
$action = New-ScheduledTaskAction -Execute 'powershell' -Argument 'C:\NetStrap\secgroup_update.ps1'
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 4am
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "Daily Secgroup Update" -Description "Created by Managed.com"

#run newly-created task
" "
"Running task..."
Start-ScheduledTask -TaskName "Daily Secgroup Update"

#sleep 2 seconds
Start-Sleep -s 2

#prompt user to exit
" "
Write-Host "Done! Press any key to exit..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
