Param(
 [Parameter(Mandatory=$true)]
 [string]$FirstName,
 [Parameter(Mandatory=$true)]
 [string]$LastName,
  [Parameter(Mandatory=$true)]
 [string]$Email,
 [Parameter(Mandatory=$true)]
 [string]$Department
)
# Connect to the Azure Active Directory
#$AzureADCred = Get-Credential -Message "Please sign in with Admin Credentials"
# ^ Does not work if/when MFA is enabled.
#Connect-AzureAD #-Credential $AzureADCred 


#Don't touch
$userName = "$FirstName.$LastName@domain.com"
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$TempPass = ([char[]](Get-Random -Input $(48..57 + 65..90 + 97..122) -Count 10)) -join ""

# Update the password. I advise you stick with capital first of four letters, then four numbers (it is easy to communicate and avoids confusion).
$PasswordProfile.Password = $TempPass

# cmdlet to Create AD User
New-AzureADUser -DisplayName "${FirstName} ${LastName}" `
                -UserPrincipalName $userName `
                -UserType Member -Department $Department `
                -OtherMails $Email `
                -MailNickName "${FirstName}.${LastName}" `
                -PasswordProfile $PasswordProfile `
                -Surname $LastName -GivenName $FirstName `
                -UsageLocation "US" `
                -AccountEnabled $true ` | Select $userName, $PasswordProfile.Password
$PasswordProfile.Password | clip
Write-Host "The password for $userName has been copied to your clipboard." -ForegroundColor Cyan
Write-EventLog -EventId 31337 -LogName "Windows PowerShell" -Message "$user created $username" -Source "PowerShell" -EntryType SuccessAudit
