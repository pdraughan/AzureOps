$nic = Get-AzNetworkInterface -ResourceGroupName "Resource Group Name" -Name "Name of Network Interface"

$nic.EnableAcceleratedNetworking = $true


$nic | Set-AzNetworkInterface