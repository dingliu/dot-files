#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
Applies and validates a small set of Microsoft Edge and Windows Widgets policies.

.DESCRIPTION
Configures machine-level registry-backed policies that disable Microsoft Edge
Startup Boost, background mode, browser sign-in, and the sidebar; suppress the
first-run experience; and disable Windows Widgets.

The script is idempotent: values that already match are left unchanged. By
default, it applies the desired state and then validates every value. Use
-ValidateOnly to perform a read-only compliance check.

This script does not remove Microsoft Edge, WebView2, or user-installed PWAs.

.PARAMETER ValidateOnly
Skips configuration and only checks the current machine-level policy values.

.EXAMPLE
.\Set-EdgeDormantPolicies.ps1

Applies all policies and validates the result.

.EXAMPLE
.\Set-EdgeDormantPolicies.ps1 -ValidateOnly

Checks compliance without changing policy values.

.OUTPUTS
System.Management.Automation.PSCustomObject

Returns one validation record per policy. If any value is noncompliant, the
script writes the results and terminates with an error.

.NOTES
Run from an elevated Windows PowerShell or PowerShell session. Restart Edge
after applying the policies. A sign-out or restart may be required for Widgets.
Edge policy state can also be reviewed at edge://policy.

.LINK
https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies/

.LINK
https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-newsandinterests
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
param(
    [Parameter()]
    [switch] $ValidateOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$policyDefinitions = @(
    [pscustomobject]@{
        Description = 'Disable Edge Startup Boost'
        Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
        Name        = 'StartupBoostEnabled'
        Value       = 0
    }
    [pscustomobject]@{
        Description = 'Disable Edge background mode'
        Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
        Name        = 'BackgroundModeEnabled'
        Value       = 0
    }
    [pscustomobject]@{
        Description = 'Suppress the Edge first-run experience'
        Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
        Name        = 'HideFirstRunExperience'
        Value       = 1
    }
    [pscustomobject]@{
        Description = 'Disable browser profile sign-in'
        Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
        Name        = 'BrowserSignin'
        Value       = 0
    }
    [pscustomobject]@{
        Description = 'Disable the Edge sidebar'
        Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
        Name        = 'HubsSidebarEnabled'
        Value       = 0
    }
    [pscustomobject]@{
        Description = 'Disable Windows Widgets'
        Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh'
        Name        = 'AllowNewsAndInterests'
        Value       = 0
    }
)

function Get-PolicyValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $Name
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    $property = Get-ItemProperty -LiteralPath $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $property) {
        return $null
    }

    return $property.$Name
}

function Set-PolicyValue {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [pscustomobject] $Policy
    )

    $currentValue = Get-PolicyValue -Path $Policy.Path -Name $Policy.Name
    if ($currentValue -eq $Policy.Value) {
        Write-Verbose "Already compliant: $($Policy.Name) = $($Policy.Value)"
        return
    }

    $target = "$($Policy.Path)\$($Policy.Name)"
    if ($PSCmdlet.ShouldProcess($target, "Set REG_DWORD to $($Policy.Value)")) {
        if (-not (Test-Path -LiteralPath $Policy.Path)) {
            New-Item -Path $Policy.Path -Force | Out-Null
        }

        New-ItemProperty -LiteralPath $Policy.Path -Name $Policy.Name `
            -PropertyType DWord -Value $Policy.Value -Force | Out-Null

        Write-Verbose "Configured: $($Policy.Name) = $($Policy.Value)"
    }
}

if (-not $ValidateOnly) {
    foreach ($policy in $policyDefinitions) {
        Set-PolicyValue -Policy $policy -WhatIf:$WhatIfPreference -Confirm:$false
    }
}

$validationResults = foreach ($policy in $policyDefinitions) {
    $actualValue = Get-PolicyValue -Path $policy.Path -Name $policy.Name

    [pscustomobject]@{
        Policy      = $policy.Name
        Description = $policy.Description
        Expected    = $policy.Value
        Actual      = $actualValue
        Compliant   = ($actualValue -eq $policy.Value)
    }
}

$validationResults

if ($WhatIfPreference -and -not $ValidateOnly) {
    Write-Warning 'Validation reflects current state because -WhatIf made no changes.'
}

if (($validationResults.Compliant -contains $false) -and -not $WhatIfPreference) {
    throw 'One or more policies are not compliant. Review the validation results above.'
}

Write-Verbose 'All Microsoft Edge and Windows Widgets policies are compliant.'
