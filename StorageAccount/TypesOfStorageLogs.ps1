# This sets the storage account to send logs to the Log Analytics Workspace in a different subscription.
# There are 3 different type of logs that this script can set; to be used in conjunction with AllStorageAccountstoOneWorkspace.ps1

$StorageAccountName = "xxxxxx"

New-AzOperationalInsightsStorageInsight -Name $StorageAccountName -Workspace (Get-AzOperationalInsightsWorkspace -ResourceGroupName $WorkspaceRG -Name $WorkspaceName) -StorageAccountResourceId 'StorageAccountResourceId' -StorageAccountKey 'StorageAccountKey' -Tables WADWindowsEventLogsTable -Force
New-AzOperationalInsightsStorageInsight -Name $StorageAccountName -Workspace (Get-AzOperationalInsightsWorkspace -ResourceGroupName $WorkspaceRG -Name $WorkspaceName) -StorageAccountResourceId 'StorageAccountResourceId' -StorageAccountKey 'StorageAccountKey' -Tables WADETWEventTable -Force
New-AzOperationalInsightsStorageInsight -Name $StorageAccountName -Workspace (Get-AzOperationalInsightsWorkspace -ResourceGroupName $WorkspaceRG -Name $WorkspaceName) -StorageAccountResourceId 'StorageAccountResourceId' -StorageAccountKey 'StorageAccountKey' -Tables WADServiceFabric*EventTable -Force
