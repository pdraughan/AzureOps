# use this collection of scripts to get all the VPN info
$RG1          = "resource group name"
$Connection16 = "Connection Name"
$connection6  = Get-AzureRmVirtualNetworkGatewayConnection -Name $Connection16 -ResourceGroupName $RG1

# Uncomment the following group of variables if you are resizing
<# $VNetName1 = "VNet Name"
 $GWName1 = "VPN Gateway name"
 $vngw1 = Get-AzureRmVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1
#> 
<# Resize the Gateway
Resize-AzureVNetGateway -VNetName $vngw1.Name -GatewaySKU "HighPerformance"
#>

<# This section changes the VPN Gateway based on the $newpolicy6 variable
 $newpolicy6 = New-AzureRmIpsecPolicy -IkeEncryption AES256 -IkeIntegrity SHA384 -DhGroup DHGroup24 `
                                      -IpsecEncryption AES256 -IpsecIntegrity SHA256 -PfsGroup PFS24 `
                                       -SALifeTimeSeconds 28800 -SADataSizeKilobytes 4608000

                                       Set-AzureRmVirtualNetworkGatewayConnection -VirtualNetworkGatewayConnection $connection6 `
                                           -IpsecPolicies $newpolicy6 `
                                           -UsePolicyBasedTrafficSelectors $True
#>

# the below spits out the current config of the VPN gateway, representing whatever you did/didn't do to it
$connection6  = Get-AzureRmVirtualNetworkGatewayConnection -Name $Connection16 -ResourceGroupName $RG1
$connection6.IpsecPolicies


<# To reset the VPN Gateway
$gw = Get-AzureRmVirtualNetworkGateway -Name VNet1GW -ResourceGroup TestRG1
Reset-AzureRmVirtualNetworkGateway -VirtualNetworkGateway $gw
#>