param([string]$OutputJson)

$out = @()
try {
  $vols = Get-BitLockerVolume -ErrorAction Stop
  foreach($v in $vols) {
    $out += [PSCustomObject]@{
      MountPoint = $v.MountPoint
      VolumeStatus = $v.VolumeStatus
      EncryptionPercentage = $v.EncryptionPercentage
      KeyProtector = ($v.KeyProtector | Select-Object -ExpandProperty KeyProtectorType) -join ","
      AutoUnlock = $v.AutoUnlockEnabled
    }
  }
} catch {
  $out = "Get-BitLockerVolume not available or requires admin. Error: $_"
}

if($OutputJson){ $out | ConvertTo-Json -Depth 6 | Out-File $OutputJson -Encoding UTF8 }
$out
