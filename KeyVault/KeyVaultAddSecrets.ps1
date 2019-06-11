
Param(
 [Parameter(Mandatory=$true)]
 [string]$SecretName,
 [Parameter(Mandatory=$true)]
 [string]$SecretValue
)
#be in the right subscription context before running.
#$subscriptionID = (Get-AzSubscription | ogv -PassThru).SubscriptionID
#Set-AzContext -Subscription $subscriptionID

$SecretsSecretvalue = ConvertTo-SecureString $SecretValue -AsPlainText -Force
#$KeyVaults = (Get-AzKeyVault | ogv -PassThru).VaultName

foreach ($KeyVault in $KeyVaults)
{
Set-AzKeyVaultSecret -VaultName $KeyVault -Name $SecretName -SecretValue $SecretsSecretvalue
Write-Host "$SecretName added to $KeyVault" -ForegroundColor Green
}
