
# Due to potential Network interruption, this should ONLY be run after business hours.

Connect-AzAccount
Get-AzSubscription | Out-GridView -PassThru -OutVariable sub
Set-AzContext -Subscription $sub.id

$ServiceEndpoint = (Get-AzVirtualNetworkAvailableEndpointService -Location eastus | Select-Object Name | Out-GridView -Title "Select ALL of the Endpoints you need available on this subnet" -OutputMode Multiple).Name
Get-AzVirtualNetwork | Select-Object Name, ResourceGroupName, Subnets | Out-GridView -Title "Choose the VNet whose subnets you wish to modify" -PassThru -outvariable VirtualNetwork

$Name = $VirtualNetwork.Name
$rg = $VirtualNetwork.ResourceGroupName

Get-AzVirtualNetwork -Name $Name -ResourceGroupName $rg | Get-AzVirtualNetworkSubnetConfig | Select-Object Name, AddressPrefix, ServiceEndpoints, Id | Out-GridView -Title "Choose ONE Subnet to modify" -PassThru -OutVariable Subnet

$SubnetName = $Subnet.Name
$SubnetPrefix = $Subnet.AddressPrefix
$subnetId = $subnet.Id
$prevServiceEndpoints = $Subnet.ServiceEndpoints.Service
$AllServiceEndpoints = ([array]$prevServiceEndpoints + $ServiceEndpoint | Select-Object -Unique)


Get-AzVirtualNetwork `
    -ResourceGroupName $rg `
    -Name $Name | Set-AzVirtualNetworkSubnetConfig `
    -Name $SubnetName  `
    -AddressPrefix $SubnetPrefix `
    -ServiceEndpoint $AllServiceEndpoints | Set-AzVirtualNetwork

# Now Prepping Storage Account #
$KeyVaultName = (Get-AzKeyVault | Out-GridView -PassThru).VaultName
Add-AzKeyVaultNetworkRule -VaultName $KeyVaultName -VirtualNetworkResourceId $subnetId

# if IP range/address is needed
# Add-AzKeyVaultNetworkRule -VaultName $KeyVaultName -IpAddressRange "16.17.18.0/24"

#allow trusted by Azure Services
Update-AzKeyVaultNetworkRuleSet -VaultName $KeyVaultName -Bypass AzureServices

#set to DENY so that the above is in effect
Update-AzKeyVaultNetworkRuleSet -VaultName $KeyVaultName -DefaultAction Deny