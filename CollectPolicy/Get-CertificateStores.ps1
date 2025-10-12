param([string]$OutputJson)

$stores = @("Cert:\LocalMachine\My","Cert:\LocalMachine\Root","Cert:\LocalMachine\TrustedPublisher","Cert:\CurrentUser\My")
$out = @{}
foreach($s in $stores) {
  try {
    $c = Get-ChildItem -Path $s -ErrorAction Stop | Select-Object Subject,Thumbprint,NotAfter,NotBefore,Issuer
    $out[$s] = $c
  } catch {
    $out[$s] = "unable to read store or empty"
  }
}

if($OutputJson){ $out | ConvertTo-Json -Depth 8 | Out-File $OutputJson -Encoding UTF8 }
$out
