# be in the desired subscription
$subscriptionID = (Get-AzSubscription | ogv -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID

$workspaceId = "xxxxxx"
$workspaceKey = "xxxxxxxxxxxxxxxxxxx"

$PublicSettings = @{"workspaceId" = $workspaceId}
$ProtectedSettings = @{"workspaceKey" = $workspaceKey}

$chooseONEVMSS = (get-azvmss | ogv -PassThru)

# Get information about the scale set
$vmss = Get-AzVmss `
          -ResourceGroupName $chooseONEVMSS.ResourceGroupName `
          -VMScaleSetName $chooseONEVMSS.Name

Add-AzVmssExtension `
-VirtualMachineScaleSet $vmss `
-Name "Microsoft.EnterpriseCloud.Monitoring" `
-Publisher "Microsoft.EnterpriseCloud.Monitoring" `
-Type "MicrosoftMonitoringAgent" `
-TypeHandlerVersion 1.0 `
-AutoUpgradeMinorVersion $true `
-Setting $PublicSettings `
-ProtectedSetting $ProtectedSettings

# Update the scale set and apply the Custom Script Extension to the VM instances
Update-AzVmss `
-ResourceGroupName $vmss.ResourceGroupName `
-Name $vmss.Name `
-VirtualMachineScaleSet $vmss