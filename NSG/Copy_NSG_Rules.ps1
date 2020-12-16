<#
  .DESCRIPTION 
Copies the rules of from one NSG to a new NSG.

  .PARAMETER nsgOrigin
  name of NSG that you want to copy  
  .PARAMETER nsgDestination
  name new NSG
  .PARAMETER rgName
  Resource Group Name of source NSG 
  .PARAMETER rgNameDest
  Resource Group Name when you want the new NSG placed 

  .EXAMPLE
  ./Copy_NSG_Rules.ps1 -nsgOrigin "sourceNSG" -nsgDestination "RG-New-NSG" -rgName "RG-OG-NSG" -rgNameDest "New NSG name"

  .NOTES
#>

Param(
    [Parameter(Mandatory = $true)]
    [string]$nsgOrigin,
    [Parameter(Mandatory = $true)]
    [string]$nsgDestination,
    [Parameter(Mandatory = $true)]
    [string]$rgName,
    [Parameter(Mandatory = $true)]
    [string]$rgNameDest
  )

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
    $nsgruleParams = @{
        NetworkSecurityGroup     = $newNsg
        Name                     = $nsgRule.Name
        Protocol                 = $nsgRule.Protocol
        SourcePortRange          = $nsgRule.SourcePortRange
        DestinationPortRange     = $nsgRule.DestinationPortRange
        SourceAddressPrefix      = $nsgRule.SourceAddressPrefix
        DestinationAddressPrefix = $nsgRule.DestinationAddressPrefix
        Priority                 = $nsgRule.Priority
        Direction                = $nsgRule.Direction
        Access                   = $nsgRule.Access
    }

    Add-AzNetworkSecurityRuleConfig @nsgruleParams
} 
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $newNsg 
