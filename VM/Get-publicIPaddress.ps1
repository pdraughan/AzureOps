$subs = Get-AzSubscription 
foreach ($Sub in $Subs) { 
    $SelectSub = Select-AzSubscription -SubscriptionName $Sub.Name 

$RG = Get-AzResourceGroup 


foreach ($Group in $RG) {



Get-AzPublicIpAddress -ResourceGroupName $group.ResourceGroupName | Select Name,ResourceGroupName,IpAddress,ID,PublicIpAllocationMethod | Export-Csv PublicIPs1.csv -Append -NoTypeInformation
} 
}