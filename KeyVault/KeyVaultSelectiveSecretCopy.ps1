function KeyVaultHunting{
Get-AzSubscription | ogv -PassThru | Set-AzContext
# when going to runbook, set context intentionally.

$KeyVault = (Get-AzKeyVault | Out-GridView -Title "Desired secret is found where?" -PassThru).VaultName

$GoingIntoKeyVault = (Get-AzKeyVault | Out-GridView -Title "Going into..." -PassThru).VaultName
$secrets = (Get-AzKeyVaultSecret -VaultName $KeyVault| ogv -OutputMode Multiple)
}

function CopyMoveSecret {
KeyVaultHunting
    foreach($secret in $secrets){
        $theSecretValue = (Get-AzKeyVaultSecret -Name $secret.name -VaultName $KeyVault).SecretValueText
                    $SecretsSecretvalue = ConvertTo-SecureString $theSecretValue -AsPlainText -Force
                    Set-AzKeyVaultSecret -VaultName $GoingIntoKeyVault -Name $secret.name -SecretValue $SecretsSecretvalue -ContentType $secret.contenttype | Out-Null
                }
}

do {
try {CopyMoveSecret}
catch {write-host "Something went wrong. What did you do!?" -ForegroundColor Green
Start-Sleep 5
}
finally {
Read-Host "Did you need move more secrets? [Y] or [N]?" -OutVariable Again
}
}
while ($Again -eq "Y")