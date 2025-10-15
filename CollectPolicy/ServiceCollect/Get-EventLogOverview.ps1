<#
.SYNOPSIS
  列出本机事件日志概况（LogName, RecordCount, OldestRecord, NewestRecord）
.PARAMETER OutputJson
  可选，输出 json 文件路径
#>
param([string]$OutputJson)

# 需要管理员读取部分日志（如 Security）
$logs = @()
try {
  $logNames = Get-WinEvent -ListLog * 2>$null
} catch {
  # fallback to wevtutil
  $wn = & wevtutil el 2>$null
  $logNames = $wn | ForEach-Object { $_ }
}

foreach($l in $logNames) {
  try {
    if($l -is [string]) { $name = $l } else { $name = $l.LogName }
    # use Get-WinEvent for metadata
    $meta = Get-WinEvent -ListLog $name -ErrorAction Stop
    $recCount = $meta.RecordCount
    $oldest = if($meta.OldestRecordNumber -ne $null) {
      try { (Get-WinEvent -FilterHashtable @{LogName=$name;MaxEvents=1;Reverse=$false} -ErrorAction SilentlyContinue).TimeCreated } catch { $null }
    } else { $null }
    $newest = if($recCount -gt 0) {
      try { (Get-WinEvent -FilterHashtable @{LogName=$name;MaxEvents=1} -ErrorAction SilentlyContinue).TimeCreated } catch { $null }
    } else { $null }

    $logs += [PSCustomObject]@{
      LogName = $name
      RecordCount = $recCount
      Oldest = $oldest
      Newest = $newest
    }
  } catch {
    # ignore single log error
  }
}

if($OutputJson) { $logs | ConvertTo-Json -Depth 6 | Out-File -FilePath $OutputJson -Encoding UTF8 }
$logs | Sort-Object -Property RecordCount -Descending
