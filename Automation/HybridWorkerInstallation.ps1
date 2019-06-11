# should work if/when the onprem script does not install/call for azurerm cmdlets
#Login-AzAccount
Install-Script -Name New-OnPremiseHybridWorker

$Values = @{
AAResourceGroupName = "xxxx"
OMSResourceGroupName = "xxxxx" 
SubscriptionID = "xxxxxxxx"
WorkspaceName = "xxxxxx"
AutomationAccountName = "xxxxx" 
HybridGroupName = "xxxxx"
}

New-OnPremiseHybridWorker.ps1 @Values