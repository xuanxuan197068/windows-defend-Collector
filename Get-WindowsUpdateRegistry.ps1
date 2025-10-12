<#
.SYNOPSIS
  读取 Windows Update / AU 相关的注册表策略和值
#>
param([string]$OutputJson)

$keys = @(
  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate",
  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU",
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
)

$out = @{}
foreach($k in $keys) {
  if(Test-Path $k) {
    $out[$k] = Get-ItemProperty -Path $k -ErrorAction SilentlyContinue | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider
  } else {
    $out[$k] = $null
  }
}

# also check specific known policy names
$check = @{
  "NoAUShutdownOption" = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
  "SetAutoRestartNotificationConfig" = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
}
foreach($name in $check.Keys) {
  $path = $check[$name]
  if(Test-Path $path) {
    try { $val = (Get-ItemProperty -Path $path -ErrorAction Stop).$name } catch { $val = $null }
    $out["Policy_$name"] = $val
  } else { $out["Policy_$name"] = $null }
}

if($OutputJson){ $out | ConvertTo-Json -Depth 6 | Out-File $OutputJson -Encoding UTF8 }
$out
