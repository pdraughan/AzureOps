Get-AzUserAssignedIdentity -ResourceGroupName ProEHRDev-HST-MI -OutVariable prouseraccessuami1
$prouseraccessuami1ID = $prouseraccessuami1.PrincipalId

$AADGroup = (Get-AzureADGroup | ogv -Title "Choose the AD Group to which you want to join the VM" -PassThru)
$i = 0
foreach ($ID in $prouseraccessuami1ID)
{
#Using the desired GroupID and created User Assigned Managed Identity, adds the Principle/apps to the AD Group
Add-AzureAdGroupMember -ObjectId $AADGroup.ObjectId -RefObjectId $id
Write-Host ""$ID[$i].Name"has been successfully added to"$AADGroup.DisplayName"" -ForegroundColor Green
$i = $i + 1
}
