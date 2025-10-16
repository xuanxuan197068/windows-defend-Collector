<#
Get-WindowsUpdateLog.ps1
极简：使用 Get-WindowsUpdateLog 获取 Windows 更新日志；
出错时输出错误码，不中断。

Return codes:
  0 = 成功
  1 = Get-WindowsUpdateLog 无输出或文件未生成
  2 = Get-WindowsUpdateLog 执行失败
#>

[CmdletBinding()]
param(
    # 可选：输出日志文件路径；未指定则默认存放到当前目录下的 WindowsUpdate.log
    [string]$OutputPath = "$(Get-Location)\WindowsUpdate.log"
)

$ErrorActionPreference = 'Continue'
$overall = 0

Write-Output ("Run at: {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))

try {
    Write-Output ("---Attempt: Get-WindowsUpdateLog -LogPath `"{0}`"---" -f $OutputPath)

    # 确保目录存在
    $dir = Split-Path -Path $OutputPath -Parent
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    # 运行 Get-WindowsUpdateLog
    $out = Get-WindowsUpdateLog -LogPath $OutputPath -ErrorAction Stop

    if ((Test-Path -LiteralPath $OutputPath) -and ((Get-Item $OutputPath).Length -gt 0)) {
        Write-Output ("[INFO] Windows Update log generated successfully: {0}" -f $OutputPath)
        $overall = 0
    } else {
        Write-Output ("[WARN] Get-WindowsUpdateLog executed but file not found or empty: {0}" -f $OutputPath)
        $overall = 1
    }
}
catch {
    Write-Output ("[ERROR] Get-WindowsUpdateLog failed: {0}" -f $_.Exception.Message)
    $overall = 2
}

$global:LASTEXITCODE = $overall
Write-Output ("RETURN_CODE={0}" -f $overall)
