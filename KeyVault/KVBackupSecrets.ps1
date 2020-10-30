<#
.SYNOPSIS
  This script will backup a given KeyVault(s) keys and secrets to another Key Vault, where no user should have active access.

.PARAMETER SubID
subscriptionID contexted needed for this runbook, where the targeted KeyVault(s) are located. Can accept multiple subscription IDs.
.PARAMETER BackupGoingToKV
subscriptionID contexted needed for this runbook, where the targeted KeyVault(s) are located. Can accept multiple subscription IDs.

#NOTE: deprecation warnings are suppressed due to secretvalue upcoming issue mentioned below.
#>
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

$servicePrincipalConnection = Get-AutomationConnection -Name 'AzureRunAsConnection'        
Connect-AzAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null

$subID = ""

$KeyVaults = "", ""
$BackupGoingToKV = ""

Set-AzContext -Subscription $subID | Out-Null

    foreach ($Vault in $KeyVaults) {

        $secrets = (Get-AzKeyVaultSecret -VaultName $Vault).Name

        foreach ($secret in $secrets) {
            $theSecretValue = (Get-AzKeyVaultSecret -Name $secret -VaultName $Vault).SecretValueText
            $BackupName = ("backup" + "-" + $Vault + "-" + $Secret)
            ###NOTE: if/when az.keyvault module is updated to v3 or greater, the following line should not be needed as the secret output should already be a secure string.
            $SecretsSecretvalue = ConvertTo-SecureString $theSecretValue -AsPlainText -Force
            Set-AzKeyVaultSecret -VaultName $BackupGoingToKV -Name $BackupName -SecretValue $SecretsSecretvalue | Out-Null
        }

    }
