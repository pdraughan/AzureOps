Param(
 [Parameter(Mandatory=$true)]
 [string]$CustomScriptURI,
 [Parameter(Mandatory=$true)]
 [string]$ScriptPS1FileName
)

$customConfig = @{
  "fileUris" = (,"$CustomScriptURI");
  "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File $ScriptPS1FileName"
}

$chooseONEVMSS = (get-azvmss | ogv -PassThru)

# Get information about the scale set
$vmss = Get-AzVmss `
          -ResourceGroupName $chooseONEVMSS.ResourceGroupName `
          -VMScaleSetName $chooseONEVMSS.Name


# Add the Custom Script Extension
$vmss = Add-AzVmssExtension `
  -VirtualMachineScaleSet $vmss `
  -Name "customScript" `
  -Publisher "Microsoft.Compute" `
  -Type "CustomScriptExtension" `
  -TypeHandlerVersion 1.9 `
  -Setting $customConfig

# Update the scale set and apply the Custom Script Extension to the VM instances
Update-AzVmss `
-ResourceGroupName $vmss.ResourceGroupName `
-Name $vmss.Name `
-VirtualMachineScaleSet $vmss