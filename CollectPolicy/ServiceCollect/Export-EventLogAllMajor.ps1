<#
.SYNOPSIS
  导出常见关键事件日志到 EVTX 文件（System/Application/Security/Setup/...）
.PARAMETER OutputDir
  必填，导出目录（会创建子目录 Logs）
.PARAMETER IncludeExtra
  可选，额外的 logname 数组（例如 "Microsoft-Windows-Sysmon/Operational"）
#>
param(
  [Parameter(Mandatory=$true)][string]$OutputDir,
  [string[]]$IncludeExtra
)

if(-not (Test-Path $OutputDir)) { New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null }
$logsDir = Join-Path $OutputDir "Logs"
if(-not (Test-Path $logsDir)) { New-Item -Path $logsDir -ItemType Directory -Force | Out-Null }

$major = @("System","Application","Security","Setup","Windows PowerShell")
if($IncludeExtra) { $major += $IncludeExtra }

foreach($l in $major) {
  $safeName = $l -replace "[\\\/:]","_"
  $outFile = Join-Path $logsDir "$safeName.evtx"
  try {
    # Prefer wevtutil for direct EVTX export (robust)
    & wevtutil epl "$l" "$outFile" 2>$null
    if(Test-Path $outFile) {
      Write-Host "Exported $l -> $outFile"
    } else {
      Write-Warning "Export failed for $l"
    }
  } catch {
    Write-Warning "wevtutil export failed for $l"
  }
}

# optional: create a small index json
$index = Get-ChildItem -Path $logsDir -File | Select-Object Name,Length,FullName
$index | ConvertTo-Json -Depth 2 | Out-File (Join-Path $OutputDir "logs_index.json") -Encoding UTF8
Write-Host "Export complete. Logs in $logsDir"
