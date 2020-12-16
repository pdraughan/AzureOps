<#
  .DESCRIPTION 
  Once the AzureAD Group is in context, creates a system-managed identity for one or more Azure VMs.

 #>

#get the AD Group
$AADGroup = (Get-AzureADGroup | ogv -Title "Choose the AD Group to which you want to join the VM" -PassThru)
#choose subscription for the VM
$subscriptionID = (Get-AzSubscription | ogv -Title "Choose the Subscription in which the VM belongs" -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID

#Choose the VM
$VM = (Get-AzVm | ogv -Title "Choose the VM or VMs that you wish to add to the AD Group" -OutputMode Multiple)
$VMResourceGroup = $vm.ResourceGroupName

foreach ($VirtualMachine in $VM)
{
#New-AzUserAssignedIdentity - if using UserAssigned... need to research more.
Update-AzVM -ResourceGroupName $VMResourceGroup[$i] -VM $VM[$i] -AssignIdentity:$SystemAssigned

#Retrieves the updated VM info to get the new PrincipalID
Get-azvm -ResourceGroupName $VMResourceGroup[$i] -Name $vm[$i].Name -OutVariable UpdatedVMInfo

#Using the desired GroupID and Newly created System Assigned Managed Identity, adds the VM to the AD Group
Add-AzureAdGroupMember -ObjectId $AADGroup.ObjectId -RefObjectId $UpdatedVMInfo.Identity.PrincipalId
Write-Host ""$VM[$i].Name"has been successfully added to"$AADGroup.DisplayName"" -ForegroundColor Green
}