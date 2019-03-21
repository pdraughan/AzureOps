$collectionName = "RDS Collection Name"
$sessionID = (Get-RDUserSession -CollectionName $collectionName -ConnectionBroker "nameConnectionBrokerVM"| ogv -PassThru).UnifiedSessionId
$hostServer = (Get-RDUserSession | Where-Object {$_.SessionId -eq $sessionID -and $_.CollectionName -eq $collectionName}).HostServer
$user = (Get-RDUserSession | Where-Object {$_.SessionId -eq $sessionID -and $_.CollectionName -eq $collectionName}).UserName
Invoke-RDUserLogoff -UnifiedSessionID $sessionID -HostServer $hostServer -Force
Write-Host "$user has been forcibly logged out." -ForegroundColor DarkBlue
Start-Sleep -Seconds 7 
exit