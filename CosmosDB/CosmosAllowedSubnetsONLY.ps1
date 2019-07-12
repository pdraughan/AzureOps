# opens subnet endpoint and attaches CosmosDB to that Subnet
Param(
 [Parameter(Mandatory=$true)]
 [string]$CosmosDBName,
 [Parameter(Mandatory=$true)]
 [string]$CosmosDBRG
)

# Connect-AzAccount
 Get-AzSubscription | Out-GridView -PassThru -OutVariable sub
 Set-AzContext -Subscription $sub.id

$ServiceEndpoint = (Get-AzVirtualNetworkAvailableEndpointService -Location eastus | Select-Object Name | Out-GridView -Title "Select-Object ALL of the Endpoints you need available on this subnet" -OutputMode Multiple).Name
Get-AzVirtualNetwork | Select-Object Name, ResourceGroupName, Subnets |  Out-GridView -Title "Choose the VNet whose subnets you wish to modify" -PassThru -outvariable VirtualNetwork

    $VnetName = $VirtualNetwork.Name
    $VNetrg = $VirtualNetwork.ResourceGroupName

Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $VNetrg | Get-AzVirtualNetworkSubnetConfig | Select-Object Name, AddressPrefix, ServiceEndpoints | Out-GridView -Title "Choose ONE Subnet to modify" -PassThru -OutVariable Subnet

$SubnetName = $Subnet.Name
$SubnetPrefix = $Subnet.AddressPrefix

# Current known issue... This proces overwrites existing Service Endpoints. Below is the thought to preserve and add previously chosen.
# HOWEVER, then a duplicate value submission is possible.
#     $prevServiceEndpoints = $Subnet.ServiceEndpoints.Service
#     $AllServiceEndpoints = $ServiceEndpoint + $prevServiceEndpoints

Get-AzVirtualNetwork `
 -ResourceGroupName $VNetrg `
 -Name $VnetName | Set-AzVirtualNetworkSubnetConfig `
 -Name $SubnetName  `
 -AddressPrefix $SubnetPrefix `
 -ServiceEndpoint $ServiceEndpoint | Set-AzVirtualNetwork

    $vnProp = Get-AzVirtualNetwork `
  -Name $VnetName `
  -ResourceGroupName $VNetrg

 # Read-Host "Azure Cosmos DB Account Name" | Out-String -OutVariable CosmosDBName
 # Read-Host "Cosmos DB Resource Group Name" | Out-String -OutVariable CosmosDBName

  $apiVersion = "2015-04-08"

$cosmosDBConfiguration = Get-AzResource `
  -ResourceType "Microsoft.DocumentDB/databaseAccounts" `
  -ApiVersion $apiVersion `
  -ResourceGroupName $CosmosDBRG `
  -Name $CosmosDBName

  $locations = @()

foreach ($readLocation in $cosmosDBConfiguration.Properties.readLocations) {
   $locations += , @{
      locationName     = $readLocation.locationName;
      failoverPriority = $readLocation.failoverPriority;
   }
}

$virtualNetworkRules = @(@{
   id = "$($vnProp.Id)/subnets/$SubnetName";
})

if ($cosmosDBConfiguration.Properties.isVirtualNetworkFilterEnabled) {
   $virtualNetworkRules = $cosmosDBConfiguration.Properties.virtualNetworkRules + $virtualNetworkRules
}

$cosmosDBProperties = @{
   databaseAccountOfferType      = $cosmosDBConfiguration.Properties.databaseAccountOfferType;
   consistencyPolicy             = $cosmosDBConfiguration.Properties.consistencyPolicy;
   ipRangeFilter                 = $cosmosDBConfiguration.Properties.ipRangeFilter;
   locations                     = $locations;
   virtualNetworkRules           = $virtualNetworkRules;
   isVirtualNetworkFilterEnabled = $True;
}

Set-AzResource `
  -ResourceType "Microsoft.DocumentDB/databaseAccounts" `
  -ApiVersion $apiVersion `
  -ResourceGroupName $CosmosDBRG `
  -Name $CosmosDBName `
  -Properties $CosmosDBProperties


$UpdatedcosmosDBConfiguration = Get-AzResource `
  -ResourceType "Microsoft.DocumentDB/databaseAccounts" `
  -ApiVersion $apiVersion `
  -ResourceGroupName $CosmosDBRG `
  -Name $CosmosDBName

$news = $UpdatedcosmosDBConfiguration.Properties
Write-Host "$news" -ForegroundColor Green
# WARNING: This does NOT allow for Portal access. That needs fixed...
