param([string]$OutputJson)

$out = @{}
try {
  $mpStatus = Get-MpComputerStatus -ErrorAction Stop
  $mpPref = Get-MpPreference -ErrorAction Stop
  $out.Status = $mpStatus | Select-Object AMServiceEnabled,AntispywareEnabled,AntivirusEnabled,RealTimeProtectionEnabled,AMProductVersion,AntivirusSignatureVersion
  $out.Preference = $mpPref
} catch {
  $out.Error = "Get-Mp* commands not available. Ensure Windows Defender module is present and run as admin."
}

if($OutputJson){ $out | ConvertTo-Json -Depth 8 | Out-File $OutputJson -Encoding UTF8 }
$out
