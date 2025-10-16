<#
Get-WindowsDefenderStatus.ps1
极简风格：逐项输出 Windows Defender 相关策略/状态、不抛异常、末尾 RETURN_CODE

Return code convention (script-internal, 最终返回值见最后):
  0 - 至少一项成功
  1 - Get-MpComputerStatus 失败或无结果
  2 - Get-MpPreference 失败或无结果
  3 - Windows Defender 服务 (WinDefend) 查询失败或无结果
  4 - 注册表策略读取失败或无结果
  5 - 以上全部步骤均失败
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$overall = 0
$anySuccess = $false

Write-Output ("Run at: {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))

# 1) Get-MpComputerStatus - 防护状态（首选）
try {
    Write-Output '---Attempt: Get-MpComputerStatus (Protection Status)---'
    $mpStatus = Get-MpComputerStatus -ErrorAction Stop
    if ($null -ne $mpStatus -and ($mpStatus | Measure-Object).Count -gt 0) {
        $mpStatus | Format-List * | Out-String | Write-Output
        $anySuccess = $true
    } else {
        Write-Output '[WARN] Get-MpComputerStatus returned no result.'
        if ($overall -lt 1) { $overall = 1 }
    }
}
catch {
    Write-Output ("[ERROR] Get-MpComputerStatus failed: {0}" -f $_.Exception.Message)
    if ($overall -lt 1) { $overall = 1 }
}

# 2) Get-MpPreference - Defender 配置/策略项
try {
    Write-Output '---Attempt: Get-MpPreference (Preferences / Policy)---'
    $mpPref = Get-MpPreference -ErrorAction Stop
    if ($null -ne $mpPref -and ($mpPref | Measure-Object).Count -gt 0) {
        $mpPref | Format-List * | Out-String | Write-Output
        $anySuccess = $true
    } else {
        Write-Output '[WARN] Get-MpPreference returned no result.'
        if ($overall -lt 2) { $overall = 2 }
    }
}
catch {
    Write-Output ("[ERROR] Get-MpPreference failed: {0}" -f $_.Exception.Message)
    if ($overall -lt 2) { $overall = 2 }
}

# 4) 注册表策略（本地/组策略覆盖）
try {
    Write-Output '---Attempt: Registry read HKLM:\SOFTWARE\Microsoft\Windows Defender ---'
    $rk1 = 'HKLM:\SOFTWARE\Microsoft\Windows Defender'
    if (Test-Path -LiteralPath $rk1) {
        $vals1 = Get-ItemProperty -Path $rk1 -ErrorAction Stop
        Write-Output ("[REG] {0}:" -f $rk1)
        $vals1 | Format-List * | Out-String | Write-Output
        $anySuccess = $true
    } else {
        Write-Output ("[WARN] Registry key not found: {0}" -f $rk1)
        if ($overall -lt 4) { $overall = 4 }
    }
}
catch {
    Write-Output ("[ERROR] Reading registry {0} failed: {1}" -f $rk1, $_.Exception.Message)
    if ($overall -lt 4) { $overall = 4 }
}

try {
    Write-Output '---Attempt: Registry read HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender (policy overrides) ---'
    $rk2 = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'
    if (Test-Path -LiteralPath $rk2) {
        $vals2 = Get-ItemProperty -Path $rk2 -ErrorAction Stop
        Write-Output ("[REG] {0}:" -f $rk2)
        $vals2 | Format-List * | Out-String | Write-Output
        $anySuccess = $true
    } else {
        Write-Output ("[WARN] Registry key not found: {0}" -f $rk2)
        if ($overall -lt 4) { $overall = 4 }
    }
}
catch {
    Write-Output ("[ERROR] Reading registry {0} failed: {1}" -f $rk2, $_.Exception.Message)
    if ($overall -lt 4) { $overall = 4 }
}


# 计算最终返回码
if ($anySuccess) {
    $final = 0
} else {
    # 若没有任何成功输出，采用上面记录的最大错误等级（>=1）
    # 若 overall 未被设置过（仍为0）则置为 5（全部失败）
    if ($overall -eq 0) { $final = 5 } else { $final = $overall }
}

$global:LASTEXITCODE = $final
Write-Output ("RETURN_CODE={0}" -f $final)
