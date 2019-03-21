
#name of NSG that you want to copy 
$nsgOrigin = "Base-Stage" 
#name new NSG  
$nsgDestination = "Base-Nsg" 
#Resource Group Name of source NSG 
$rgName = "rg-Script" 
#Resource Group Name when you want the new NSG placed 
$rgNameDest = "NSGs" 
 

 
$nsg = Get-AzNetworkSecurityGroup -Name $nsgOrigin -ResourceGroupName $rgName 
$nsgRules = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg 
$newNsg = Get-AzNetworkSecurityGroup -name $nsgDestination -ResourceGroupName $rgNameDest 
foreach ($nsgRule in $nsgRules) { 
    Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $newNsg  `
        -Name $nsgRule.Name  `
        -Protocol $nsgRule.Protocol `
        -SourcePortRange $nsgRule.SourcePortRange `
        -DestinationPortRange $nsgRule.DestinationPortRange `
        -SourceAddressPrefix $nsgRule.SourceAddressPrefix  `
        -DestinationAddressPrefix $nsgRule.DestinationAddressPrefix `
        -Priority $nsgRule.Priority `
        -Direction $nsgRule.Direction `
        -Access $nsgRule.Access 
} 
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $newNsg 
