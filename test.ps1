[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = 'Continue'
$overall = 0

Write-Output ("Target Path: {0}" -f $Path)

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Output ("[WARN] Path not found: {0}" -f $Path)
    $overall = 1
} else {
    try {
        $acl = Get-Acl -LiteralPath $Path -ErrorAction Stop

        # DACL = Access
        Write-Output '---DACL (Access) SDDL---'
        try {
            $daclSddl = $acl.GetSecurityDescriptorSddlForm([System.Security.AccessControl.AccessControlSections]::Access)
            Write-Output $daclSddl
        } catch {
            Write-Output "[ERROR] Failed to get DACL: $($_.Exception.Message)"
            if ($overall -eq 0) { $overall = 2 }
        }

        # SACL = Audit（通常需要管理员 + SeSecurityPrivilege）
        Write-Output '---SACL (Audit) SDDL---'
        try {
            $saclSddl = $acl.GetSecurityDescriptorSddlForm([System.Security.AccessControl.AccessControlSections]::Audit)
            Write-Output $saclSddl
        } catch {
            Write-Output "[ERROR] Failed to get SACL (may require admin privileges): $($_.Exception.Message)"
            if ($overall -eq 0) { $overall = 3 }
        }

    } catch {
        Write-Output "[ERROR] Get-Acl failed: $($_.Exception.Message)"
        $overall = 4
    }
}

$global:LASTEXITCODE = $overall
Write-Output ("RETURN_CODE={0}" -f $overall)
