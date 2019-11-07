
Param(
 [Parameter(Mandatory=$true)]
 [string]$SecretName,
 [Parameter(Mandatory=$true)]
 [string]$SecretValue
)
#be in the right subscription context before running.
Get-AzSubscription | ogv -PassThru | Set-AzContext

$SecretsSecretvalue = ConvertTo-SecureString $SecretValue -AsPlainText -Force
$KeyVaults = (Get-AzKeyVault | Select-Object VaultName, ResourceGroupName | ogv -PassThru).VaultName

foreach ($KeyVault in $KeyVaults)
{
Set-AzKeyVaultSecret -VaultName $KeyVault -Name $SecretName -SecretValue $SecretsSecretvalue
Write-Host "$SecretName added to $KeyVault" -ForegroundColor Green
}
