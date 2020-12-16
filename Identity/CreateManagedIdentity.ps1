<#
  .DESCRIPTION 
  Once the AzureAD Group is in context, creates a system-managed identity for a chosen AzureVM.
#>

#get the AD Group
$groupID = (Get-AzureADGroup | ogv -Title "Choose the AD Group to which you want to join the VM" -PassThru).ObjectID
#choose subscription for the VM
$subscriptionID = (Get-AzSubscription | ogv -Title "Choose the Subscription in which the VM belongs" -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID

#Choose the VM
$VM = (Get-AzVm | ogv -Title "Choose the VM" -PassThru)
$VMName = $VM.Name
$VMResourceGroup = $vm.ResourceGroupName

#Creates the System Assigned Managed Identity
Update-AzVM -ResourceGroupName $VMResourceGroup -VM $VM -AssignIdentity:$SystemAssigned
#Retrieves the updated VM info to get the new PrincipalID
Get-azvm -ResourceGroupName $VMResourceGroup -Name $VMName -OutVariable UpdatedVMInfo

#Using the desired GroupID and Newly created System Assigned Managed Identity, adds the VM to the AD Group
Add-AzureAdGroupMember -ObjectId $groupID -RefObjectId $UpdatedVMInfo.Identity.PrincipalId
Write-Host "$VMName has been successfully added to $AADGroup" -ForegroundColor Green