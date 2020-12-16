# Reseting a Local User Password for a VMSS
In the event that your VMSS is NOT domain joined, and you need to reset a local admin/user password, the "Reset Password" option in the blade _should_ work (after a re-image of all Instances). However, in the event that the aforementioned actions do not fix it, then you need to manually delete the VMAccess Extension, and add it back, with your desired Username and Password.
## Manually updating a Username and Password
The following actions will create (or update if the username already exists) a Username and Password with local Admin privileges on all VMs within a VMSS.

    1. Azure Portal > VMSS > Settings > Extension > VMAccessAgent
    2. Uninstall
    3. Navigate to the Settings > Instances and wait for all instances to return to a "Running" Status, refreshing the view as needed.
    4. When all Instances have returned to Running, execute the following PowerShell script (and supply appropriate parameters)
```
    $vmssName = "NAME OF THE VMSS"
$vmssResourceGroup = "RG OF THE VMSS"
$publicConfig = @{"UserName" = "DESIRED USERNAME"}
$privateConfig = @{"Password" = "DESIRED PASSWORD MORE THAN 12 CHARACTERS"}
 
$extName = "VMAccessAgent"
$publisher = "Microsoft.Compute"
Connect-AzAccount
$subscriptionID = (Get-AzSubscription | ogv -Title "Choose the Subscription containing the VMSS" -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID
$vmss = Get-AzVmss -ResourceGroupName $vmssResourceGroup -VMScaleSetName $vmssName
$vmss = Add-AzVmssExtension -VirtualMachineScaleSet $vmss -Name $extName -Publisher $publisher -Setting $publicConfig -ProtectedSetting $privateConfig -Type $extName -TypeHandlerVersion "2.0" -AutoUpgradeMinorVersion $true
Update-AzVmss -ResourceGroupName $vmssResourceGroup -Name $vmssName -VirtualMachineScaleSet $vmss
```

When the Instances again return to Running Status, you should be able to RDP into with the above provided Username and Password.