#name of NSG that you want to copy
$nsgOrigin = "Subnet-nsg"
#name new NSG
$nsgDestination = "Subnet"
#Resource Group Name of source NSG
$rgName = "RGName"
#Resource Group Name when you want the new NSG placed
$rgNameDest = "DestNSGName"

#Region of new NSG
$nsglocation = "EastUS"
cls

$nsg = Get-AzNetworkSecurityGroup -Name $nsgOrigin -ResourceGroupName $rgName
$nsgRules = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg

#NOTE: if creating in a new subscription, run the above first, then change subscription context to run the remaining bit.

$newNsg = New-AzNetworkSecurityGroup -name $nsgDestination -ResourceGroupName $rgNameDest -location $nsglocation -Force:$true
foreach ($nsgRule in $nsgRules) {
    Write-Host $nsgRule.Name -ForegroundColor Green
    $params = @{
        'NetworkSecurityGroup' = $newNsg
        'Name'= $nsgRule.Name
        'Protocol' = $nsgRule.Protocol
        'SourcePortRange' = $nsgRule.SourcePortRange
        'DestinationPortRange' = $nsgRule.DestinationPortRange
        'SourceAddressPrefix' = $nsgRule.SourceAddressPrefix
        'DestinationAddressPrefix' = $nsgRule.DestinationAddressPrefix
        'Priority' = $nsgRule.Priority
        'Direction' = $nsgRule.Direction
        'Access' = $nsgRule.Access
    }
    $params
    Add-AzNetworkSecurityRuleConfig @params | Out-Null
    #break
   
}
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $newNsg