[CmdletBinding()]
param(
    # 要获取的最新日志条数，默认 50
    [int]$Count = 50
)

$ErrorActionPreference = 'Continue'
$overall = 0


# 构造并运行 wevtutil 命令
$wevtCmd = "wevtutil qe `"Microsoft-Windows-LAPS/Operational`" /c:$Count /rd:true /f:text"
Write-Output ("---Run: {0}---" -f $wevtCmd)

# 使用 cmd /c 调用以获得原始文本输出，并捕获 exit code
$out = & cmd /c $wevtCmd 2>&1
$code = $LASTEXITCODE

# 打印原始输出（若有）
if ($out -and $out.Count -gt 0) {
    $out -join [Environment]::NewLine | Write-Output
}

# 决定返回码
if ($code -ne 0) {
    Write-Output ("[ERROR] wevtutil exited with code {0}." -f $code)
    $overall = 2
} else {
    if (-not $out -or $out.Count -eq 0 -or ($out -join '').Trim() -eq '') {
        Write-Output "[INFO] wevtutil returned no events."
        $overall = 1
    } else {
        $overall = 0
    }
}

# 不抛异常；同步 LASTEXITCODE 并输出最终 RETURN_CODE
$global:LASTEXITCODE = $overall
Write-Output ("RETURN_CODE={0}" -f $overall)
