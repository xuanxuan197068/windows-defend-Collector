param([string]$OutputJson)

$txt = auditpol /get /category:* 2>&1
$out = $txt -join "`n"

if($OutputJson){ $out | Out-File $OutputJson -Encoding UTF8 }
$out
