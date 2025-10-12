param([string]$OutputJson)

$out = @{}
# check if LAPS module present
try {
  Import-Module AdmPwd.PS -ErrorAction Stop
  $out.Module = "AdmPwd.PS available"
  $out.LAPSComputers = Get-AdmPwdPassword -ErrorAction SilentlyContinue
} catch {
  $out.Module = "AdmPwd.PS not installed"
}

# Check for GPO registry locations that may hold LAPS settings (best-effort)
$paths = @(
  "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd",
  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LAPS",
  "HKLM:\SOFTWARE\Microsoft\LAPS"
)
foreach($p in $paths) {
  $out[$p] = if(Test-Path $p) { Get-ItemProperty -Path $p -ErrorAction SilentlyContinue | Select-Object * -ExcludeProperty PS* } else { $null }
}

if($OutputJson){ $out | ConvertTo-Json -Depth 8 | Out-File $OutputJson -Encoding UTF8 }
$out
