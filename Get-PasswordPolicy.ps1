<#
.SYNOPSIS
  获取本地或域的密码策略（min length, complexity, max age...）

.PARAMETER OutputJson
#>
param([string]$OutputJson)

$result = @{}

# 1) 若 AD module 可用且在域中，优先读取域密码策略
try {
  Import-Module ActiveDirectory -ErrorAction Stop
  $domain = (Get-ADDomain -ErrorAction Stop)
  if($domain) {
    $pw = Get-ADDefaultDomainPasswordPolicy
    $result.Scope = "Domain"
    $result.Policy = $pw | Select-Object -Property MinPasswordLength,PasswordHistoryCount,MaxPasswordAge,MinPasswordAge,ComplexityEnabled,LockoutThreshold,LockoutDuration
  }
} catch {
  # fallback to local
  $result.Scope = "Local"
  # net accounts 字段解析
  $na = net accounts 2>&1
  $result.NetAccounts = ($na -join "`n")
  # secedit export 获取更详细的本地策略
  $tmp = Join-Path $env:TEMP "secpol_$(Get-Random).inf"
  secedit /export /cfg $tmp 2>$null
  if(Test-Path $tmp) {
    $sec = Get-Content $tmp -ErrorAction SilentlyContinue
    $result.Secedit = ($sec -join "`n")
    Remove-Item $tmp -ErrorAction SilentlyContinue
  }
}

if($OutputJson){ $result | ConvertTo-Json -Depth 6 | Out-File $OutputJson -Encoding UTF8 }
$result
