#Connect-azaccount
$groupID = (Get-AzureADGroup | ogv -Title "Choose the AD Group to which you want to join the VM" -PassThru).ObjectID
$subscriptionID = (Get-AzSubscription | ogv -Title "Choose the Subscription in which your VM exists" -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID | Out-Null
$VM = (Get-AzVm| ogv -Title "Choose the VM you want joined to the AD Group" -OutputMode Multiple)
$VMID = $VM.VMID

foreach ($VirtualM in $VM)
{
#New-AzUserAssignedIdentity - if using UserAssigned... need to research more.
Update-AzVM -ResourceGroupName $vm.ResourceGroupName -VM $vm -AssignIdentity:$SystemAssigned
Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -OutVariable newVM
$RefOb = $newVM.Identity.PrincipalId
}

Add-AzureAdGroupMember -ObjectId $groupID -RefObjectId $RefOb

