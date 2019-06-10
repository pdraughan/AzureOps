#be in the right subscription context before running.
Param(
 [Parameter(Mandatory=$true)]
 [string]$SecretName,
 [Parameter(Mandatory=$true)]
 [string]$SecretValue
)

$SecretsSecretvalue = ConvertTo-SecureString $SecretValue -AsPlainText -Force
$KeyVaults = (Get-AzKeyVault | ogv -PassThru).VaultName

foreach ($KeyVault in $KeyVaults)
{
Set-AzKeyVaultSecret -VaultName $KeyVault -Name $SecretName -SecretValue $SecretsSecretvalue
Write-Host "$SecretName added to $KeyVault" -ForegroundColor Green
}
