#Connect to AD
Connect-azuread

#get the AD Group
$AADGroup = (Get-AzureADGroup | ogv -Title "Choose the AD Group to which you want to join the Service Principals" -PassThru)

#Choose the VM
$AzureADServicePrincipals = (Get-AzureADServicePrincipal -Top 10000 | ogv -Title "Choose the Enterprise Application(s) that you wish to add to the AD Group" -OutputMode Multiple)

foreach ($AzADServicePrincipal in $AzureADServicePrincipals)
{
Add-AzureADGroupMember -ObjectId $AADGroup.ObjectId -RefObjectId $AzureADServicePrincipals[$i].ObjectId

Write-Host ""$AzADServicePrincipal.DisplayName"has been successfully added to"$AADGroup.DisplayName"" -ForegroundColor Green
$i = $i + 1
}
$i = 0