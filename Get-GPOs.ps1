<#
.SYNOPSIS
  导出/列出本机或域 GPO 信息
.PARAMETER OutputJson
.PARAMETER ExportHtml
  如果指定则输出 gpresult HTML 报告
#>
param(
  [string]$OutputJson,
  [string]$ExportHtml
)

$out = @{}

try {
  Import-Module GroupPolicy -ErrorAction Stop
  $gpos = Get-GPO -All
  $out.GPOCount = $gpos.Count
  $out.GPOs = $gpos | Select-Object DisplayName,Id,DomainName,CreationTime,ModificationTime
} catch {
  # fallback: gpresult
  $out.Note = "GroupPolicy module not available; using gpresult"
  if($ExportHtml) {
    gpresult /h $ExportHtml 2>$null
    $out.GPResultHtml = $ExportHtml
  } else {
    $tmp = Join-Path $env:TEMP "gpresult_$(Get-Random).html"
    gpresult /h $tmp 2>$null
    $out.GPResultHtml = $tmp
  }
}

if($OutputJson){ $out | ConvertTo-Json -Depth 6 | Out-File $OutputJson -Encoding UTF8 }
$out
