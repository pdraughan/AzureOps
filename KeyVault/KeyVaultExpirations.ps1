# get all vaults in a subscription
$KeyVaults = (Get-AzKeyVault).VaultName
$daysWarning = "30"

# for ExpireDate, can include ALL versions by having the parameter be "-IncludeVersions" or only the most current, by using "-Versions Current"

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
                Else
                    {
                    Out-Null
                    }
            }
}