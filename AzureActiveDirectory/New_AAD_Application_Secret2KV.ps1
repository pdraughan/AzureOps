<#
  .DESCRIPTION 
  Create a new AzureAD Application, a secret, and place that secret into an interactively chosen Key Vault. Default expiration is one year from creation, and adjustment is not contained herein.

  .PARAMETER AADAppName
  Desired name of the Azure AD Application  

  .EXAMPLE
  ./New_AAD_Application_Secret2KV.ps1 -AADAppName "specialName"

  .NOTES
  Requires user interaction to choose desired subscription and Key Vault to which the secret should be stored. Assumes Connect-AzureAD and Connect-AzAccount have been run.
#>

Param(
  [Parameter(Mandatory = $true)]
  [string]$AADAppName
)

$newAADApp = New-AzureADApplication -DisplayName $AADAppName
$1yr = (Get-Date).AddYears(1)
Get-AzSubscription | ogv -PassThru -Title "Choose the Subscription containing the Key Vault to which you want to place the secret" | Set-AzContext | Out-Null

$KeyVault = (Get-AzKeyVault | Select-Object VaultName, ResourceGroupName | ogv -PassThru -Title "Choose the Key Vault where you want to save the secret").VaultName

$aadappsecret = New-AzureADApplicationPasswordCredential -ObjectId $newAADApp.objectid -CustomKeyIdentifier "Secret in $($KeyVault)"

$secretvalue = ConvertTo-SecureString $aadappsecret.value -AsPlainText -Force

$secret = Set-AzKeyVaultSecret -VaultName $KeyVault -Name $AADAppName -SecretValue $Secretvalue -ContentType "for AzureAD App $($AADAppName)" -Expires $1yr

write-host "DisplayName: $AADAppName AppID: $($newaadapp.appid) and its secret has been written to $keyvault key vault." -ForegroundColor Green
