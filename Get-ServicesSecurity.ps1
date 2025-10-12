param([string]$OutputJson, [string[]]$ServiceNames)

$out = @()

if(-not $ServiceNames) {
  $svcs = Get-Service | Where-Object {$_.Status -ne $null} | Select-Object Name -First 200
  $ServiceNames = $svcs.Name
}

foreach($n in $ServiceNames) {
  try {
    $s = Get-Service -Name $n -ErrorAction Stop
    $sd = sc.exe sdshow $n 2>$null
    $out += [PSCustomObject]@{
      Name = $s.Name
      DisplayName = $s.DisplayName
      Status = $s.Status
      StartType = (Get-CimInstance -ClassName Win32_Service -Filter "Name='$($s.Name)'" | Select-Object -ExpandProperty StartMode)
      ServiceSd = ($sd -join "`n")
    }
  } catch {
    $out += [PSCustomObject]@{ Name = $n; Error = "$_" }
  }
}

if($OutputJson){ $out | ConvertTo-Json -Depth 8 | Out-File $OutputJson -Encoding UTF8 }
$out
