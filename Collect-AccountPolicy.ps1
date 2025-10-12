<#
.SYNOPSIS
  收集 Windows 帐户/密码策略以及 Windows LAPS 策略设置。
.DESCRIPTION
  - 通过 secedit 导出本地安全策略（[System Access]）以读取密码策略（与语言无关）。
  - 从注册表读取 Windows LAPS 策略：
      HKLM\Software\Microsoft\Policies\LAPS
      HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\LAPS
      HKLM\Software\Microsoft\Windows\CurrentVersion\LAPS\Config
  返回标准化对象：
    Category（类别）, Name（名称）, Scope（作用域）, Source（来源）, Path（路径）, Current（当前值）, Raw（原始）
#>
[CmdletBinding()]
param(
  [string]$ComputerName = $env:COMPUTERNAME,
  [switch]$AsJson
)

function Convert-IniToHashtable {
  param([string[]]$Lines)
  $result = @{}
  $section = ''
  foreach ($line in $Lines) {
    $trim = $line.Trim()
    if ($trim -match '^\s*;') { continue }
    if ($trim -match '^\[(.+)\]\s*$') {
      $section = $Matches[1]
      if (-not $result.ContainsKey($section)) { $result[$section] = @{} }
      continue
    }
    if ($section -and $trim -match '^(.*?)=(.*)$') {
      $key = $Matches[1].Trim()
      $val = $Matches[2].Trim()
      $result[$section][$key] = $val
    }
  }
  return $result
}

function Get-AccountPolicyCore {
  [CmdletBinding()]
  param()

  $items = @()

  # 1) 来自 secedit 的密码/锁定策略
  $tmp = Join-Path $env:TEMP ("secpol_{0}.inf" -f ([Guid]::NewGuid().ToString('N')))
  try {
    secedit /export /mergedpolicy /cfg $tmp | Out-Null
    if (Test-Path $tmp) {
      $ini = Get-Content -LiteralPath $tmp -Encoding Unicode
      $h = Convert-IniToHashtable -Lines $ini
      if ($h.ContainsKey('System Access')) {
        $sys = $h['System Access']
        foreach ($k in @(
          'MinimumPasswordLength','MaximumPasswordAge','MinimumPasswordAge',
          'PasswordComplexity','PasswordHistorySize','LockoutBadCount',
          'ResetLockoutCount','LockoutDuration','ClearTextPassword'
        )) {
          if ($sys.ContainsKey($k)) {
            $items += [PSCustomObject]@{
              Category = 'AccountsPolicy'
              Name     = $k
              Scope    = 'Computer'
              Source   = 'secedit:[System Access]'
              Path     = "secpol.inf:[System Access]\$k"
              Current  = $sys[$k]
              Raw      = @{ Computer = $env:COMPUTERNAME }
            }
          }
        }
      }
    }
  } catch {
    $items += [PSCustomObject]@{
      Category='AccountsPolicy'; Name='secedit_export_error'; Scope='Computer'
      Source='secedit'; Path=$tmp; Current=$null; Raw=@{ Error=$_.Exception.Message }
    }
  } finally {
    if (Test-Path $tmp) { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
  }

  # 2) LAPS 注册表
  $lapsPaths = @(
    'HKLM:\Software\Microsoft\Policies\LAPS',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\LAPS',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\LAPS\Config'
  )
  foreach ($p in $lapsPaths) {
    if (Test-Path $p) {
      try {
        $props = Get-ItemProperty -LiteralPath $p
        foreach ($prop in ($props.PSObject.Properties | Where-Object { $_.MemberType -eq 'NoteProperty' })) {
          $items += [PSCustomObject]@{
            Category = 'LAPS'
            Name     = $prop.Name
            Scope    = 'Computer'
            Source   = 'Registry'
            Path     = "$p\$($prop.Name)"
            Current  = $prop.Value
            Raw      = @{ }
          }
        }
      } catch {
        $items += [PSCustomObject]@{
          Category='LAPS'; Name='registry_read_error'; Scope='Computer'
          Source='Registry'; Path=$p; Current=$null; Raw=@{ Error=$_.Exception.Message }
        }
      }
    } else {
      $items += [PSCustomObject]@{
        Category='LAPS'; Name='PathMissing'; Scope='Computer'
        Source='Registry'; Path=$p; Current=$null; Raw=@{ }
      }
    }
  }

  return $items
}

$results = Get-AccountPolicyCore
if ($AsJson) { $results | ConvertTo-Json -Depth 6 } else { $results }