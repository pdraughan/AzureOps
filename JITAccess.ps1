Login-AzureRmAccount
Select-AzureRmSubscription (Get-AzureRMSubscription | Out-GridView -Title "Select your Azure Subscription" -PassThru)
# Select the Azure Resource Group and VM
$ResourceGroupName = (Get-AzureRmResourceGroup | Out-GridView -Title "Select your Resource Group" -PassThru).ResourceGroupName
$VMName = (Get-AzureRmVM -ResourceGroupName $ResourceGroupName  | Out-GridView -Title "Select your Virtual Machine" -PassThru).Name
# Minutes:Enter a time greater than 6 minutes, less than 61
# Hours: not 0
$hours = Read-Host "Enter the number of hours to open port 3389 on VM $VMName"
#$minutes is an available variable either in place of, or in conjunction with, $hours
$ip = "10.2.0.7"
# Use the following line instead of 10.2.0.7 if running locally and not from the jumpBox
##Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
$VmNetworkdetails= (((Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VmName).NetworkProfile).NetworkInterfaces).Id
$NIC = $VmNetworkdetails.substring($VmNetworkdetails.LastIndexOf("/")+1)
$NICIP = Get-AzureRmNetworkInterface -Name $NIC -ResourceGroupName $ResourceGroupName

Invoke-ASCJITAccess -ResourceGroupName $ResourceGroupName -VM $VMName -Port 3389 -Hours $hours -AddressPrefix $ip

# we have a RemoteApp RDP available for users from our JumpBox
Write-Host "Please copy down the Private IP and proceed to AnyVM for your RDP access" -ForegroundColor Red
Get-AzureRmNetworkInterfaceIpConfig -NetworkInterface $nicIP | Select $VMName,PrivateIpAddress

# Since it is a RemoteApp powershell window, I want it to close by force
Start-Sleep -Seconds 15 
exit