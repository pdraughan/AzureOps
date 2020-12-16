<#
.SYNOPSIS
  This script will backup a given KeyVault(s) keys and secrets to another Key Vault, where no user should have active access. Expects a "runas" account as this is run from an Azure Automation account.

.PARAMETER SubID
subscriptionID contexted needed for this runbook, where the targeted KeyVault(s) are located. Can accept multiple subscription IDs.
.PARAMETER BackupGoingToKV
subscriptionID contexted needed for this runbook, where the targeted KeyVault(s) are located. Can accept multiple subscription IDs.

# NOTE: deprecation warnings can be suppressed if you're using an older version of the az.keyvault module.
# Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
#>


$servicePrincipalConnection = Get-AutomationConnection -Name 'AzureRunAsConnection'        
Connect-AzAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null

# Get-AzSubscription | ogv -PassThru | Set-AzContext
# when going to runbook, set context intentionally.

$subID = ""
$KeyVaults = "", ""
$BackupGoingToKV = ""

Set-AzContext -Subscription $subID | Out-Null
    foreach ($Vault in $KeyVaults) {
        $secrets = (Get-AzKeyVaultSecret -VaultName $Vault).Name
        foreach ($secret in $secrets) {
            $theSecretValue = (Get-AzKeyVaultSecret -Name $secret -VaultName $Vault).SecretValue
            $BackupName = ("backup" + "-" + $Vault + "-" + $Secret)
            $secretValueText = '';
            $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($theSecretValue)
        try {
            $secretValueText = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
        }
        finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr)
        }
            $SecretsSecretvalue = ConvertTo-SecureString $secretValueText -AsPlainText -Force
            Set-AzKeyVaultSecret -VaultName $BackupGoingToKV -Name $BackupName -SecretValue $SecretsSecretvalue | Out-Null
        }
    }