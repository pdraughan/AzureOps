#JIT cmdlets have updated. Needs MAJOR rework to use Set-AzJitNetworkAccessPolicy and related

Login-AzAccount
Select-AzSubscription (Get-AzSubscription | Out-GridView -Title "Select your Azure Subscription" -PassThru)
# Select the Azure Resource Group and VM
$ResourceGroupName = (Get-AzResourceGroup | Out-GridView -Title "Select your Resource Group" -PassThru).ResourceGroupName
$VMName = (Get-AzVM -ResourceGroupName $ResourceGroupName  | Out-GridView -Title "Select your Virtual Machine" -PassThru).Name
# Minutes:Enter a time greater than 6 minutes, less than 61
# Hours: not 0
$hours = Read-Host "Enter the number of hours to open port 3389 on VM $VMName"
#$minutes is an available variable either in place of, or in conjunction with, $hours
$ip = "10.2.0.7"
# Use the following line instead of 10.2.0.7 if running locally and not from the jumpBox
##Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
$VmNetworkdetails= (((Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName).NetworkProfile).NetworkInterfaces).Id
$NIC = $VmNetworkdetails.substring($VmNetworkdetails.LastIndexOf("/")+1)
$NICIP = Get-AzNetworkInterface -Name $NIC -ResourceGroupName $ResourceGroupName

Invoke-ASCJITAccess -ResourceGroupName $ResourceGroupName -VM $VMName -Port 3389 -Hours $hours -AddressPrefix $ip

Write-Host "The Private IP is on your clipboard, please proceed to AnyVM for your RDP access" -ForegroundColor Red
Get-AzNetworkInterfaceIpConfig -NetworkInterface $nicIP | Select-Object $VMName,PrivateIpAddress | clip

Start-Sleep -Seconds 15 
exit