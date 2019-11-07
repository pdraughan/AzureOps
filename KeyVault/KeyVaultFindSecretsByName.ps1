$i = 1
$subscriptionID = (Get-AzSubscription | ogv -Title "choose one or more subscriptions to check" -OutputMode Multiple).SubscriptionID
Read-Host "What do you seek?" -OutVariable letters
$seek = "*$letters*"
foreach ($sub in $subscriptionID)
{
Set-AzContext -Subscription $sub | Out-Null

$KeyVaults = (Get-AzKeyVault).VaultName

foreach ($KV in $KeyVaults)
{
$secrets = (Get-AzKeyVaultSecret -VaultName $KV).Name
    foreach ($secret in $secrets) {
    if ($secret -like $seek)
        {
            $theSecretValue = (Get-AzKeyVaultSecret -Name $secret -VaultName $KV).SecretValueText
            $AdditionalInfo = (Get-AzKeyVaultSecret -Name $secret -VaultName $KV).ContentType
        Write-Host "$secret : $theSecretValue in the $KV. Additional Information: $AdditionalInfo" -ForegroundColor Green
        }
    else
    {
        }

    }
}
}