# use this to get all the VPN info
$RG1          = "resource group name"
$Connection16 = "Connection Name"
$VNetName1 = "VNet Name"
$GWName1 = "VPN Gateway name"


$lngw = Get-AzureRmLocalNetworkGateway -Name "LocalNetworkGateway" -ResourceGroupName $RG1
$connection6  = Get-AzureRmVirtualNetworkGatewayConnection -Name $Connection16 -ResourceGroupName $RG1

$vnet1      = Get-AzureRmVirtualNetwork -Name $VNetName1 -ResourceGroupName $RG1
$subnet1    = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet1


$vngw1 = Get-AzureRmVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1

$newpolicy6 = New-AzureRmIpsecPolicy -IkeEncryption AES256 -IkeIntegrity SHA384 -DhGroup DHGroup24 `
                                       -IpsecEncryption AES256 -IpsecIntegrity SHA256 -PfsGroup PFS24 `
                                       -SALifeTimeSeconds 28800 -SADataSizeKilobytes 4608000

                          

Set-AzureRmVirtualNetworkGatewayConnection -VirtualNetworkGatewayConnection $connection6 `
                                           -IpsecPolicies $newpolicy6 `
                                           -UsePolicyBasedTrafficSelectors $True


$connection6  = Get-AzureRmVirtualNetworkGatewayConnection -Name $Connection16 -ResourceGroupName $RG1
$connection6.IpsecPolicies


Resize-AzureVNetGateway -VNetName $vngw1.Name -GatewaySKU "HighPerformance"

$lngw = Get-AzureRmLocalNetworkGateway -Name "CAHCPSI" -ResourceGroupName $RG1


# For resets

$gw = Get-AzureRmVirtualNetworkGateway -Name VNet1GW -ResourceGroup TestRG1
Reset-AzureRmVirtualNetworkGateway -VirtualNetworkGateway $gw