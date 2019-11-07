
Param(
 [Parameter(Mandatory=$true)]
 [string]$NewRGName,
 [Parameter(Mandatory=$true)]
 [string]$KeyVaultName
)
$Location = LocationDropDown
$secretvalue = ConvertTo-SecureString "Intentionally Left Blank" -AsPlainText -Force

#Choose subscription under which the resource is to be made
$subscriptionID = (Get-AzSubscription | ogv -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID

#Create Resource group for KeyVault
New-AzResourceGroup -Name $NewRGName -Location $Location

New-AzKeyVault -Name "$KeyVaultName" -ResourceGroupName "$NewRGName" -Location "$Location"
Start-Sleep -Seconds 15
Set-AzureKeyVaultSecret -VaultName "$KeyVaultName" -Name 'CosmosUri' -SecretValue $secretvalue
Set-AzureKeyVaultSecret -VaultName "$KeyVaultName" -Name 'CosmosAuthKey' -SecretValue $secretvalue
Set-AzureKeyVaultSecret -VaultName "$KeyVaultName" -Name 'CosmosDBName' -SecretValue $secretvalue
Set-AzureKeyVaultSecret -VaultName "$KeyVaultName" -Name 'RedisConnectionString' -SecretValue $secretvalue
Set-AzureKeyVaultSecret -VaultName "$KeyVaultName" -Name 'ServiceBusConnectionString' -SecretValue $secretvalue

Set-AzKeyVaultAccessPolicy -VaultName "$KeyVaultName" -ObjectId 95f17f90-2bdf-41f9-97c8-ed4df79cbf94 -PermissionsToKeys get, create, delete, list, update, import, backup, restore, recover -PermissionsToSecrets get, list, set, delete, backup, restore, recover -PermissionsToCertificates get, delete, list, create, import, update, deleteissuers, getissuers, listissuers, managecontacts, manageissuers, setissuers, recover, backup, restore -PermissionsToStorage delete, deletesas, get, getsas, list, listsas, regeneratekey, set, setsas, update, recover, backup, restore

Get-AzKeyVault -VaultName "$KeyVaultName" | select VaultName