param([string]$OutputJson)

$reg = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$out = @{}
if(Test-Path $reg) {
  $props = Get-ItemProperty -Path $reg -ErrorAction SilentlyContinue
  $pick = "EnableLUA","ConsentPromptBehaviorAdmin","ConsentPromptBehaviorUser","PromptOnSecureDesktop"
  foreach($p in $pick) {
    $out[$p] = (Get-ItemProperty -Path $reg -Name $p -ErrorAction SilentlyContinue).$p
  }
} else {
  $out.Error = "UAC registry key not found"
}

if($OutputJson){ $out | ConvertTo-Json -Depth 6 | Out-File $OutputJson -Encoding UTF8 }
$out
