<#
.SYNOPSIS
  This script will backup a given KeyVault(s) keys and secrets to another Key Vault, where no user should have active access.

.PARAMETER SubID
subscriptionID contexted needed for this runbook, where the targeted KeyVault(s) are located. Can accept multiple subscription IDs.
.PARAMETER BackupGoingToKV
subscriptionID contexted needed for this runbook, where the targeted KeyVault(s) are located. Can accept multiple subscription IDs.

# Known Limits
due to KV Access Policy limitations, this will only work where the user executing (or AA RunAsAccount) has permissions.

# Alternative
https://docs.microsoft.com/en-us/powershell/module/az.keyvault/backup-azkeyvaultsecret
Key Vault now has "backup" cmdlets, that puts the secrets, keys, or certs into a storage account, where files are only readable when imported to another KV.
#>


$subID = ""
$BackupGoingToKV = "backup-demo"

foreach ($sub in $subID) {
    Set-AzContext -Subscription $sub | Out-Null

    $KeyVaults = (Get-AzKeyVault).VaultName

    foreach ($Vault in $KeyVaults) {

        $secrets = (Get-AzKeyVaultSecret -VaultName $Vault).Name
        $keys = (Get-AzKeyVaultKey -VaultName $Vault).Name
        foreach ($secret in $secrets) {
            Backup-AzKeyVaultSecret -VaultName $KeyVault -Name $secret -OutputFile <storage Account Location> -Force
        }
        foreach ($key in $keys) {
            Backup-AzKeyVaultKey -VaultName $KeyVault -Name $key -OutputFile <storage account> -Force
        }
    }
}