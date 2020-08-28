<#
.SYNOPSIS
  Deletes old files
.DESCRIPTION
  Connects to the listed storage account and deletes any file(s) in the designated folder, not modified in the last 7 days

.PARAMETER SubscriptionID
   Manually Set
   Allows you to specify the subscription upon which you'll be searching for the Resource Group  

.PARAMETER ResourceGroupName
   Manually Set
   Allows you to specify the resource group containing the VMs to create the notification criteria.  

#>
$connectionName = "AzureRunAsConnection"
try {
  # Get the connection "AzureRunAsConnection "
  $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

  "Logging in to Azure..."
  Connect-AzAccount `
    -ServicePrincipal `
    -TenantId $servicePrincipalConnection.TenantId `
    -ApplicationId $servicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null
}
catch {
  if (!$servicePrincipalConnection) {
    $ErrorMessage = "Connection $connectionName not found."
    throw $ErrorMessage
  }
  else {
    Write-Error -Message $_.Exception
    throw $_.Exception
  }
}
$subscriptionid = "GUID"
set-azcontext -subscriptionID $subscriptionid | Out-Null

#get all resource groups for the environment
$ResourceGroupName = "xxxxxx"
$StorageAccount = "XXXXXXXXX"
$sharename = "share"

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
