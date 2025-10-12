param([string]$OutputJson)

$out = @{}
try {
  $out.HotFixes = Get-HotFix | Select-Object HotFixID,Description,InstalledOn,InstalledBy
} catch {
  $out.HotFixes = "Get-HotFix not available or failed: $_"
}

# try reading from Windows Update history via COM (best-effort)
try {
  $session = New-Object -ComObject Microsoft.Update.Session
  $searcher = $session.CreateUpdateSearcher()
  $historyCount = $searcher.GetTotalHistoryCount()
  $hist = $searcher.QueryHistory(0, $historyCount)
  $out.UpdateHistoryCount = $historyCount
  $out.UpdateHistorySample = $hist | Select-Object Title,Description,Date,ResultCode -First 50
} catch {
  $out.UpdateHistory = "com interface not available or denied"
}

if($OutputJson){ $out | ConvertTo-Json -Depth 8 | Out-File $OutputJson -Encoding UTF8 }
$out
