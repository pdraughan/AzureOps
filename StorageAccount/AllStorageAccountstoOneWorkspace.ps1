#set the subscription that you want to scan
$ScanSub = "xxxxxxxx"
$DestSub = "xxxxxx"
$WorkspaceRG = "xxxxx"
$WorkspaceName = "xxxxxx"

Select-AzSubscription -Subscription $ScanSub  
# gets all storage accounts in a subsciption 
$Storage = Get-AzStorageAccount 

foreach ($stor in $Storage){

# get the Storage account key
$keys = Get-AzStorageAccountKey -Name $stor.Storageaccountname -ResourceGroupName $Stor.ResourceGroupName | where KeyName -eq "Key1" 
$StorID = $stor.ID
$Name = $stor.Storageaccountname

foreach($Key in $Keys){

# set the subscription to destination Subscription
Select-AzSubscription -Subscription $DestSub
$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $WorkspaceRG -Name $WorkspaceName

# set storeage logs to go to sentinel workspace


#write-host $key.value, $Stor.id , $workspace.name
New-AzOperationalInsightsStorageInsight -Name $Name -Workspace $workspace -StorageAccountResourceId $storID -StorageAccountKey $key.Value -Tables WADWindowsEventLogsTable -Force
New-AzOperationalInsightsStorageInsight -Name $Name"_1" -Workspace $workspace -StorageAccountResourceId $storID -StorageAccountKey $key.Value -Tables WADETWEventTable -Force
New-AzOperationalInsightsStorageInsight -Name $Name"_2" -Workspace $workspace -StorageAccountResourceId $storID -StorageAccountKey $key.Value -Tables WADServiceFabric*EventTable -Force

#set the subscription that you want to use
Select-AzSubscription -Subscription $ScanSub
}
}

