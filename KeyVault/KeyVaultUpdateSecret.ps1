
Param(
 [Parameter(Mandatory=$true)]
 [string]$SecretValue
)
# allows one Secret value to be updated in multiple KeyVaults; assumes same named Secret and multiple keyvaults. if one, remove "[0]"
$subscriptionID = (Get-AzSubscription | ogv -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID

$SecretsSecretvalue = ConvertTo-SecureString $SecretValue -AsPlainText -Force
$KeyVaults = (Get-AzKeyVault | ogv -PassThru).VaultName
$TheSecretName = (Get-AzKeyVaultSecret -VaultName $KeyVaults[0]| Select-Object Name | ogv -Title "Choose ONE Secret name to update" -PassThru).Name

foreach ($KeyVault in $KeyVaults)
{
Set-AzKeyVaultSecret -VaultName $KeyVault -Name $TheSecretName -SecretValue $SecretsSecretvalue
Write-Host "$TheSecretName updated to $KeyVault" -ForegroundColor Green
}
