$vmssName = "Name of VMSS" 
$vmssResourceGroup = "RG Name" 
$publicConfig = @{"UserName" = "UserPersonName"} 
$privateConfig = @{"Password" = "SuperSecure Password!"} 
  
$extName = "VMAccessAgent" 
$publisher = "Microsoft.Compute" 
#Login-AzAccount
$subscriptionID = (Get-AzSubscription | ogv -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID
$vmss = Get-AzVmss -ResourceGroupName $vmssResourceGroup -VMScaleSetName $vmssName 
$vmss = Add-AzVmssExtension -VirtualMachineScaleSet $vmss -Name $extName -Publisher $publisher -Setting $publicConfig -ProtectedSetting $privateConfig -Type $extName -TypeHandlerVersion "2.0" -AutoUpgradeMinorVersion $true 
Update-AzVmss -ResourceGroupName $vmssResourceGroup -Name $vmssName -VirtualMachineScaleSet $vmss 