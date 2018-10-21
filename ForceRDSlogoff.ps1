# needs improvement. Only works if user has only one session (expected behavior if you force disconnect from the collection when a user signs off)
$collectionName = "Collection Name"
$ConnectionBroker = "Broker FQDN"
$User = (Get-RDUserSession -CollectionName $collectionName -ConnectionBroker $ConnectionBroker | Select UserName,UnifiedSessionId | ogv -Title "Select the user you would like to disconnect" -PassThru).UserName
$hostServer = (Get-RDUserSession -CollectionName $collectionName -ConnectionBroker $ConnectionBroker | Where-Object {$_.UserName -eq $User -and $_.CollectionName -eq $collectionName}).HostServer
$SessionID = (Get-RDUserSession -CollectionName $collectionName -ConnectionBroker $ConnectionBroker | Where-Object {$_.UserName -eq $User -and $_.CollectionName -eq $collectionName}).UnifiedSessionId
Invoke-RDUserLogoff -UnifiedSessionID $sessionID -HostServer $hostServer -Force
Write-Host "$user has been forcibly logged out." -ForegroundColor Green
Start-Sleep -Seconds 7 
exit