$subscriptionID = (Get-AzSubscription | Out-GridView -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID

$KeyVault = (Get-AzKeyVault | Out-GridView -PassThru).VaultName

$secrets = (Get-AzKeyVaultSecret -VaultName $keyvault).Name

foreach ($secret in $secrets) {
$theSecretValue = (Get-AzKeyVaultSecret -Name $secret -VaultName $KeyVault).SecretValueText
if ($theSecretValue -eq "Intentionally Left Blank")
    {
    Write-Host "$secret : $theSecretValue" -ForegroundColor Green
    }
else
{}

}