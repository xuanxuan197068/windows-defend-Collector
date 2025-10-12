param(
  [string]$OutputJson,
  [string]$PolicyStore = "PersistentStore"  # 可用: PersistentStore, ActiveStore, or all
)

$out = @{}
try {
  if($PolicyStore -eq "all") {
    $rules = Get-NetFirewallRule -ErrorAction Stop
  } else {
    $rules = Get-NetFirewallRule -PolicyStore $PolicyStore -ErrorAction Stop
  }
  $out.Count = $rules.Count
  $out.Rules = $rules | Select-Object DisplayName,Name,Direction,Action,Enabled,Profile,PolicyStore
} catch {
  $out.Error = "Get-NetFirewallRule failed: $_"
}

if($OutputJson){ $out | ConvertTo-Json -Depth 8 | Out-File $OutputJson -Encoding UTF8 }
$out
