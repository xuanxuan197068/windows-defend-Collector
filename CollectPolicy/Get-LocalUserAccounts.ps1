<#
.SYNOPSIS
  列出本地用户账户详情（启用/禁用、描述、SID、PasswordExpired等）
  输出结果：
  名字，是否启用，描述，SID,最后登入时间，密码有效期至，密码是否可以更改，是否需要密码。
.PARAMETER OutputJson
  可选，输出到 JSON 文件
#>
param(
  [string]$OutputJson
)

# 尝试使用 Get-LocalUser（PS 5.1+）
$out = @()
try {
  $users = Get-LocalUser -ErrorAction Stop
  foreach($u in $users) {
    $obj = [PSCustomObject]@{
      Name = $u.Name
      Enabled = $u.Enabled
      Description = $u.Description
      SID = $u.SID.Value
      LastLogon = $null
      PasswordExpired = $u.PasswordExpired
      PasswordChangeable = $u.PasswordChangeable
      PasswordRequired = $u.PasswordRequired
    }
    $out += $obj
  }
} catch {
  # 兼容旧系统
  $ads = [ADSI]"WinNT://$env:COMPUTERNAME"
  foreach($child in $ads.psbase.Children) {
    if($child.SchemaClassName -eq 'User') {
      $out += [PSCustomObject]@{
        Name = $child.Name
        Enabled = -not ($child.UserFlags -band 0x2) # SCRIPT / ACCOUNTDISABLE bit
        Description = $child.Get("Description")
        SID = ($child.psbase.Invoke("objectSid") 2>$null) -join ''
        LastLogon = $null
      }
    }
  }
}

if($OutputJson) {
  $out | ConvertTo-Json -Depth 4 | Out-File -FilePath $OutputJson -Encoding UTF8
}
$out
