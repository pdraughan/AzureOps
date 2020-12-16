# This sets the storage account to send logs to the Log Analytics Workspace in a different subscription.
# There are 3 different type of logs that this script will set

New-AzOperationalInsightsStorageInsight -Name Name -Workspace (Get-AzOperationalInsightsWorkspace -ResourceGroupName sentinel -Name SentinelDev) -StorageAccountResourceId 'StorageAccountResourceId' -StorageAccountKey 'StorageAccountKey' -Tables WADWindowsEventLogsTable -Force
New-AzOperationalInsightsStorageInsight -Name Name_1 -Workspace (Get-AzOperationalInsightsWorkspace -ResourceGroupName sentinel -Name SentinelDev) -StorageAccountResourceId 'StorageAccountResourceId' -StorageAccountKey 'StorageAccountKey' -Tables WADETWEventTable -Force
New-AzOperationalInsightsStorageInsight -Name Name_2 -Workspace (Get-AzOperationalInsightsWorkspace -ResourceGroupName sentinel -Name SentinelDev) -StorageAccountResourceId 'StorageAccountResourceId' -StorageAccountKey 'StorageAccountKey' -Tables WADServiceFabric*EventTable -Force





