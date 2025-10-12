param(
  [Parameter(Mandatory=$true)][string]$Path,
  [string]$OutputJson
)

$out = @{}
try {
  if($Path -like "HKLM:*" -or $Path -like "HKCU:*") {
    $acl = Get-Acl -Path $Path -ErrorAction Stop
  } else {
    $acl = Get-Acl -Path $Path -ErrorAction Stop
  }
  $out.Path = $Path
  $out.Acl = $acl.Access | Select-Object IdentityReference,FileSystemRights,AccessControlType,IsInherited
} catch {
  $out.Error = $_.Exception.Message
}

if($OutputJson){ $out | ConvertTo-Json -Depth 6 | Out-File $OutputJson -Encoding UTF8 }
$out
