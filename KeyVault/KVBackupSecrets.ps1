Get-AzSubscription | ogv -PassThru | Set-AzContext
# when going to runbook, set context intentionally.

# $KeyVaults = (Get-AzKeyVault | Out-GridView -OutputMode Multiple).VaultName

$GoingIntoKeyVault = "$name"

foreach ($Vault in $KeyVaults) {

$secrets = (Get-AzKeyVaultSecret -VaultName $Vault).Name

    foreach($secret in $secrets){
        $theSecretValue = (Get-AzKeyVaultSecret -Name $secret -VaultName $Vault).SecretValueText
                    $BackupName = ($Vault + "-" + $Secret)
                    $SecretsSecretvalue = ConvertTo-SecureString $theSecretValue -AsPlainText -Force
                    Set-AzKeyVaultSecret -VaultName $GoingIntoKeyVault -Name $BackupName -SecretValue $SecretsSecretvalue | Out-Null
                }
}