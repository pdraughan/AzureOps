# assumes AzConnect and ADConnect have already been run
$subscriptionID = (Get-AzSubscription | ogv -OutputMode Multiple).SubscriptionID
$ADApp = (Get-AzureADGroup | ogv -PassThru)

foreach ($sub in $subscriptionID){
Set-AzContext -Subscription $sub | Out-Null

$KeyVaults = (Get-AzKeyVault).VaultName
foreach ($KeyVault in $KeyVaults)
{
Set-AzKeyVaultAccessPolicy -VaultName "$KeyVault" -ObjectId $ADApp.ObjectID -PermissionsToKeys get, list, decrypt -PermissionsToSecrets get, list -PermissionsToCertificates get, list

Write-Host ""$ADApp.DisplayName" permissions added to "$KeyVault"" -ForegroundColor Green}
}