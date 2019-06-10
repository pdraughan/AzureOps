#variables
$ResourgeGroupName = Read-Host "Please provide name of ResourgeGroup that will be used for saving the NSG logs"
$StorageAccountLogs = Read-Host "Please provide name of Storage Account that will be used for saving the NSG logs"
$retentionperiod = Read-Host "Please provide retention period"
$WorkspaceName = Read-Host "Please proved the Log Analytics Workspace Name"
$WorkspaceRG = Read-Host "Please proved the Log Analytics Workspace Resoruce Group" 


#Login to the Azure Resource Management Account
#Login-AzAccount
Register-AzResourceProvider -ProviderNamespace Microsoft.Insights

#region Get Azure Subscriptions
$subscriptions = Get-AzSubscription
$menu = @{}
for ($i = 1;$i -le $subscriptions.count; $i++) 
{
  Write-Host -Object "$i. $($subscriptions[$i-1].Name)"
  $menu.Add($i,($subscriptions[$i-1].Id))
}

[int]$ans = Read-Host -Prompt 'Enter selection'
$subscriptionID = $menu.Item($ans)
$subscription = Get-AzSubscription -SubscriptionId $subscriptionID
Set-AzContext -SubscriptionName $subscription.Name
#endregion

$subId = (Get-AzContext).Subscription.Id
$subName = (Get-AzContext).Subscription.Name


#regionGet Azure details details

$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourgeGroupName -Name $StorageAccountLogs
$NWs = Get-AzNetworkWatcher -ResourceGroupName NetworkWatcherRg 
$workspace = Get-AzOperationalInsightsWorkspace -Name $WorkspaceName -ResourceGroupName $WorkspaceRG

#endregion

Foreach($NW in $NWs){

$NWlocation = $NW.location
write-host "Looping trough $NWlocation" -ForegroundColor Yellow


#region Enable NSG Flow Logs

$nsgs = Get-AzNetworkSecurityGroup | Where-Object {$_.Location -eq $NWlocation}

Foreach($nsg in $nsgs)
    {
    Get-AzNetworkWatcherFlowLogStatus -NetworkWatcher $NW -TargetResourceId $nsg.Id
    Set-AzNetworkWatcherConfigFlowLog -NetworkWatcher $NW -TargetResourceId $nsg.Id -StorageAccountId $storageAccount.Id -EnableFlowLog $true -EnableRetention $true -RetentionInDays $retentionperiod  -EnableTrafficAnalytics -Workspace $workspace -TrafficAnalyticsInterval 60 -FormatVersion 2 -FormatType Json
    write-host "Diagnostics enabled for $nsg.Name " -BackgroundColor Green
    }


#endregion


}
