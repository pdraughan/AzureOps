Param(
 [Parameter(Mandatory=$true)]
 [string]$FilePath,
 [Parameter(Mandatory=$true)]
 [string]$CertificateName,
 [Parameter(Mandatory=$true)]
 [string]$CertPassword
)
# assumes you have proper access to upload the cert to a given KV. 
# If not, run KeyVaultAccessPermissionsxxxx.ps1 to add correct permissions (may need to modify permission list)
#be in the right subscription context before running.
$Password =  ConvertTo-SecureString -String $CertPassword -AsPlainText -Force
$KeyVaults = (Get-AzKeyVault | ogv -OutputMode Multiple).VaultName

foreach ($KeyVault in $KeyVaults)
{
    try {Import-AzKeyVaultCertificate -FilePath $FilePath -Name $CertificateName -VaultName $KeyVault -Password $Password
        Write-Host "$CertificateName added to $KeyVault" -ForegroundColor Green
        }
    catch {"That didn't work against $KeyVault"}
}
