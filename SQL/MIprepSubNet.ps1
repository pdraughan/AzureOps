# Must be run on a Powershell with ONLY Az installed
$scriptUrlBase = 'https://raw.githubusercontent.com/Microsoft/sql-server-samples/master/samples/manage/azure-sql-db-managed-instance/prepare-subnet'

$subscriptionID = (Get-AzSubscription | ogv -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID
$rg = (Get-AzResourceGroup | ogv -PassThru).ResourceGroupName
$VNet = (Get-AzVirtualNetwork | ogv -PassThru)
$subnet = (Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $Vnet | ogv -PassThru)

$parameters = @{
    subscriptionId = $subscriptionid
    resourceGroupName = $rg
    virtualNetworkName = $Vnet.Name
    subnetName = $subnet.Name
    }

Invoke-Command -ScriptBlock ([Scriptblock]::Create((iwr ($scriptUrlBase+'/prepareSubnet.ps1?t='+ [DateTime]::Now.Ticks)).Content)) -ArgumentList $parameters