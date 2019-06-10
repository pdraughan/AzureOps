#be in the right subscription context before running.


Param(
 [Parameter(Mandatory=$true)]
 [string]$ServiceUserName,
 [Parameter(Mandatory=$true)]
 [string]$Department
)
# Assumes Connect-AzureAD has already been run.

$userName = "$ServiceUserName@domain.com"
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$TempPass = ([char[]](Get-Random -Input $(48..57 + 65..90 + 97..122) -Count 12)) -join ""

# Update the password. I advise you stick with capital first of four letters, then four numbers (it is easy to communicate and avoids confusion).
$PasswordProfile.Password = $TempPass
$PasswordProfile.ForceChangePasswordNextLogin = $false
$PasswordProfile.ForceChangePasswordNextLogin = $false

New-AzureADUser -DisplayName "$ServiceUserName" `
                -UserPrincipalName $userName `
                -UserType Member -Department $Department `
                -OtherMails "RecoveryEmail@email.com" `
                -MailNickName "$ServiceUserName" `
                -PasswordProfile $PasswordProfile `
                -Surname "ServiceUser" -GivenName $ServiceUserName `
                -UsageLocation "US" `
                -AccountEnabled $true ` | Select $userName, $PasswordProfile.Password
$PasswordProfile.Password | clip

Write-Host "The password for $userName has been copied to your clipboard." -ForegroundColor Cyan
#Writes the action by whom, for what, and how, to EventLogs, to be picked up in LogAnalytics
Write-EventLog -EventId 31337 -LogName "Windows PowerShell" -Message "$user created $username" -Source "PowerShell" -EntryType SuccessAudit

Get-AzureADUser -ObjectId "$userName" -OutVariable ADObjectID
Set-AzureADUser -ObjectId $ADObjectID.objectid -PasswordPolicies DisablePasswordExpiration | Out-Null


#be in the right subscription context before running.
# dumps generated password into the chosen KeyVault
$SecretsSecretvalue = ConvertTo-SecureString $PasswordProfile.Password  -AsPlainText -Force
$KeyVaults = (Get-AzKeyVault | ogv -PassThru).VaultName
$SecretName = 

foreach ($KeyVault in $KeyVaults)
{
Set-AzKeyVaultSecret -VaultName $KeyVault -Name $ServiceUserName -SecretValue $SecretsSecretvalue -ContentType $userName
Write-Host "$SecretName added to $KeyVault" -ForegroundColor Green
}
