$RG1          = "RGName"
$Connection16 = "VPN Connection"
$VNetName1 = "vnet"
$GWName1 = "Local Gateway Name"


$lngw = Get-AzLocalNetworkGateway -Name "CAHCPSI" -ResourceGroupName $RG1
$connection6  = Get-AzVirtualNetworkGatewayConnection -Name $Connection16 -ResourceGroupName $RG1

$vnet1      = Get-AzVirtualNetwork -Name $VNetName1 -ResourceGroupName $RG1
$subnet1    = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet1


$vngw1 = Get-AzVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1

#choose your settings wisely, and compatibly with the other side of the tunnel
$newpolicy6 = New-AzIpsecPolicy -IkeEncryption AES256 -IkeIntegrity SHA384 -DhGroup DHGroup24 `
                                       -IpsecEncryption AES256 -IpsecIntegrity SHA256 -PfsGroup PFS24 `
                                       -SALifeTimeSeconds 28800 -SADataSizeKilobytes 4608000

                          

Set-AzVirtualNetworkGatewayConnection -VirtualNetworkGatewayConnection $connection6 `
                                           -IpsecPolicies $newpolicy6 `
                                           -UsePolicyBasedTrafficSelectors $True


$connection6  = Get-AzVirtualNetworkGatewayConnection -Name $Connection16 -ResourceGroupName $RG1
$connection6.IpsecPolicies


Resize-AzureVNetGateway -VNetName $vngw1.Name -GatewaySKU "HighPerformance"

$lngw = Get-AzLocalNetworkGateway -Name "Name the local Gateway" -ResourceGroupName $RG1


# For resets

$gw = Get-AzVirtualNetworkGateway -Name VNet1GW -ResourceGroup TestRG1
Reset-AzVirtualNetworkGateway -VirtualNetworkGateway $gw