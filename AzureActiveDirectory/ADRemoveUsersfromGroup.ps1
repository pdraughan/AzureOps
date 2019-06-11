# A window will appear from which you can select the AD Group from which multiple users can be removed. 
# Use your OS' multiple item key selection to utilize multiple selctions.
param(
$AdGroup = (Get-AzureADGroup | ogv -PassThru).ObjectId,
$ADGroupName = (Get-AzureADGroup -ObjectID $AdGroup).DisplayName,
$memberID = (Get-AzureADGroupMember -ObjectId $AdGroup | 
Select-Object DisplayName, UserPrincipalName, ObjectID | 
ogv -Title "Choose the person(s) to remove from the $AdGroup group" -OutputMode Multiple).objectid,
$count = ($memberID | measure).count
)
foreach ($memberid in $memberID)
{
Remove-AzureADGroupMember -MemberId $memberID -objectID $AdGroup
}
 Write-Host "$count Users removed from $AdGroupName"