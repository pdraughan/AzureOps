Select-AzureRmSubscription -Subscription "Sub GUID"
Get-AzureRMVMss | select Name, ResourceGroupName, {$_.HardwareProfile.VmSize}, {$_.StorageProfile.OsDisk.OsType}, Location | Export-Csv c:\prodVMss.csv
# Hosting SubID: b3be09f3-75e2-469e-8210-ea1ffa3a9f70
# Development 1a098b86-f5f6-4e7f-9730-0af9a05722c5