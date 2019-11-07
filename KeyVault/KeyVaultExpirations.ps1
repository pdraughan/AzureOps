$subscriptionID = (Get-AzSubscription | ogv -Title "choose one or more subscriptions to check" -OutputMode Multiple).SubscriptionID
$daysWarning = "90"

foreach ($sub in $subscriptionID)
{
Set-AzContext -Subscription $sub | Out-Null

$KeyVaults = (Get-AzKeyVault).VaultName

foreach ($KV in $KeyVaults)
{
# I can't get a Try/Catch to work for "Forbidden" errors...
     $certificates = (Get-AzKeyVaultCertificate $KV).Name
     $secrets = (Get-AzKeyVaultSecret -VaultName $KV).Name
     $keys = (Get-AzKeyVaultKey -VaultName $KV).Name
 
        foreach ($cert in $certificates)
            {
                $expireDate = (Get-AzKeyVaultCertificate -VaultName $KV -Name $cert -IncludeVersions).Expires
                try {$DaysuntilExpire = (New-TimeSpan -Start (Get-Date) -End $expireDate).Days}
                catch {$DaysuntilExpire = 360}
                   If ($DaysuntilExpire -lt $daysWarning) 
                    {
                    Write-Host "ALERT! $KV has"$cert" Certificate expiring in "$DaysuntilExpire" days"
                    }
                Elseif ($DaysuntilExpire -lt 0){
                Write-Host "$KV has $cert expired"
                }
                Else
                    {
                    Out-Null
                    }
            }

            foreach ($Secret in $secrets)
            {
                $expireDate = (Get-AzKeyVaultSecret -VaultName $KV -Name $secret -IncludeVersions).Expires
                try {$DaysuntilExpire = (New-TimeSpan -Start (Get-Date) -End $expireDate).Days}
                catch {$DaysuntilExpire = 360}
                   If ($DaysuntilExpire -lt $daysWarning)
                    {
                    Write-Host "ALERT! $KV has"$secret" Secret expiring in "$DaysuntilExpire" days"
                    }
                    Elseif ($DaysuntilExpire -lt 0){
                Write-Host "$KV has $secret expired"
                }

                Else
                    {
                    Out-Null
                    }
            }
          foreach ($key in $Keys)
            {
                $expireDate = (Get-AzKeyVaultKey -VaultName $KV).Expires
                try {$DaysuntilExpire = (New-TimeSpan -Start (Get-Date) -End $expireDate).Days}
                catch {$DaysuntilExpire = 360}
                   If ($DaysuntilExpire -lt $daysWarning)
                   { 
                    Write-Host "ALERT! $KV has"$key" Key expiring in "$DaysuntilExpire" days"
                    }
                                    Elseif ($DaysuntilExpire -lt 0){
                Write-Host "$KV has $key expired"
                }

                Else
                    {
                    Out-Null
                    }
            }
}

}