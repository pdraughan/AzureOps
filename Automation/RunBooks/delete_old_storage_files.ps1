<#
.SYNOPSIS
  Deletes old files
.DESCRIPTION
  Connects to the listed storage account and deletes any file(s) in the designated folder, not modified in the last 7 days.
  Change the "-7" if you desire a different value or want a variable number of days.

.PARAMETER SubscriptionID
   Manually Set
   Allows you to specify the subscription upon which you'll be searching for the Resource Group  

.PARAMETER ResourceGroupName
   Manually Set
   Allows you to specify the resource group containing the VMs to create the notification criteria.  

.PARAMETER StorageAccount
  Storage Account containing the Fileshare that needs cleaned.

.PARAMETER ShareName
  Name(s) of the FileShare needing the automated cleaning.
#>

# login to AZAccount (Only if being run from a runbook)
<#
  $azureADCredential = (Get-AutomationConnection -Name 'AzureRunAsConnection')
  Connect-AzAccount -Tenant $azureADCredential.TenantID -ApplicationID $azureADCredential.ApplicationID -CertificateThumbprint $azureADCredential.CertificateThumbprint -ServicePrincipal
#>

Param(
  [Parameter(Mandatory = $true)]
  [string]$ResourceGroupName,
  [Parameter(Mandatory = $true)]
  [string]$subscriptionid,
  [Parameter(Mandatory = $true)]
  [string]$StorageAccount,
  [Parameter(Mandatory = $true)]
  [string]$sharename
)

set-azcontext -subscriptionID $subscriptionid | Out-Null

$ctx = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $StorageAccount).Context  

$now = Get-Date
$7daysago = $now.AddDays(-7)#.ToString("MM/dd/yy hh:mm:ss tt")
$filesss = Get-AZStorageFile -Context $ctx -ShareName $sharename

foreach ($thing in $filesss) {  

  $lastmod = (Get-AzStorageFile -Context $ctx -sharename $sharename -Path $thing.Name).Properties.LastModified.DateTime
  if ($lastmod -lt $7daysago) {
    Write-Output "$($thing.Name) last modified on $($lastmod) and has been DELETED"
    Remove-AzStorageFile -Context $ctx -sharename $sharename -Path $thing.Name
  }
  else {
    # Do nothing
    # Write-Output "$($thing.Name) last modified on $($thing.Properties.LastModified.datetime); thereby, new enough to stay"
  }
}
