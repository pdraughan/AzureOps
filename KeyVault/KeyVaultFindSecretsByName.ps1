<#
.SYNOPSIS
  Look for a secret in any KV to which the contextual user has access. NOTE: mind your Access Policy

.PARAMETER seeking
   Provide the name of the secret that you are seeking

#>

Param(
  [Parameter(Mandatory = $true)]
  [string]$seeking
)


$subscriptionID = (Get-AzSubscription).SubscriptionID
$seek = "*$seeking*"
foreach ($sub in $subscriptionID)
{
Set-AzContext -Subscription $sub | Out-Null

$KeyVaults = (Get-AzKeyVault).VaultName

foreach ($KV in $KeyVaults)
{
    Write-Host "scanning $KV"
$secrets = (Get-AzKeyVaultSecret -VaultName $KV).Name
    foreach ($secret in $secrets) {
    if ($secret -like $seek)
        {
            $theSecretValue = (Get-AzKeyVaultSecret -Name $secret -VaultName $KV).SecretValueText
            $AdditionalInfo = (Get-AzKeyVaultSecret -Name $secret -VaultName $KV).ContentType
        Write-Host "$secret : $theSecretValue in the $KV. Additional Information: $AdditionalInfo" -ForegroundColor Green
        }
    else
    {
        Write-Host "Nothing here"
        }

    }
}
}