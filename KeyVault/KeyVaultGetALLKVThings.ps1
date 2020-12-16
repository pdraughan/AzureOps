$subscriptionID = (Get-AzSubscription | ogv -Title "choose one or more subscriptions to check" -OutputMode Multiple).SubscriptionID
$MasterList = @()
foreach ($sub in $subscriptionID) {
    Set-AzContext -Subscription $sub | Out-Null

    $KeyVaults = (Get-AzKeyVault).VaultName

    foreach ($KV in $KeyVaults) {
        # I can't get a Try/Catch to work for "Forbidden" errors...
        $certificates = (Get-AzKeyVaultCertificate $KV).Name
        $secrets = (Get-AzKeyVaultSecret -VaultName $KV).Name
        $keys = (Get-AzKeyVaultKey -VaultName $KV).Name
        foreach ($cert in $certificates) {
            $MasterList += [PSCustomObject] @{
                KeyVault    = $kv
                Type        = "Certificate"                                        
                DisplayName = $cert; 
            }
        }

        foreach ($Secret in $secrets) {
            #                $theSecretValue = (Get-AzKeyVaultSecret -Name $secret -VaultName $KV).SecretValueText
            $MasterList += [PSCustomObject] @{
                KeyVault    = $kv
                Type        = "Secret"                                        
                DisplayName = $secret;
            }

        }
        foreach ($key in $Keys) {
            $MasterList += [PSCustomObject] @{
                KeyVault    = $kv
                Type        = "Key"                                        
                DisplayName = $key; 
            }
        }
    }

}
