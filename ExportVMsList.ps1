Login-AzureRmAccount
$subscriptionID = (Get-AzureRmSubscription | ogv -PassThru).SubscriptionID
Set-AzureRmContext -Subscription $subscriptionID
Get-AzureRMVMss | select Name, ResourceGroupName, {$_.HardwareProfile.VmSize}, {$_.StorageProfile.OsDisk.OsType}, Location | Export-Csv c:\prodVMss.csv