<#
  .DESCRIPTION 
  Force an Azure Security Center compliance check to begin and await response until job completion. Does require user interaction to choose the targeted subscription for assigned Policies.

  .EXAMPLE
  ./ForceComplianceCheck.ps1

#>

Get-azsubscription | ogv -Passthru | set-azcontext
$job = Start-AzPolicyComplianceScan -AsJob
$job | Wait-Job
