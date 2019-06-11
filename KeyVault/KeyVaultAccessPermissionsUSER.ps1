# assumes AzConnect and ADConnect have already been run
#Choose subscription under which the resource is to be made
$subscriptionID = (Get-AzSubscription | ogv -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID

$KeyVaults = (Get-AzKeyVault).VaultName
#$ADApp = (Get-AzureADServicePrincipal | ogv -PassThru)
$ADApp = (Get-AzureADUser -All $true | ogv -PassThru)
foreach ($KeyVault in $KeyVaults)
{
Set-AzKeyVaultAccessPolicy -VaultName "$KeyVault" -ObjectId $ADApp.ObjectID -PermissionsToKeys get, list, decrypt -PermissionsToSecrets get, list -PermissionsToCertificates get, list

Write-Host ""$ADApp.DisplayName" permissions added to "$KeyVault"" -ForegroundColor Green}