<#
  .DESCRIPTION 
  This is the PowerShell script that allows sufficiently powerful AzureAD admins to quickly create AAD users.


  .PARAMETER FirstName
  Proper First Name of the user.  
  .PARAMETER LastName
  Proper Last Name of the user.
  .PARAMETER Email
  The email to which the password reset (and all associated notifications) will be sent. Please ensure it is a valid email able to receive MSFT emails.
  .PARAMETER UsageLocation
  Choose appropriate Country code for the users primary location (typicaly US or IN)

  .EXAMPLE
  ./create_acmuser_workflow.ps1 -FirstName Special -LastName Person -Email person@email.com -UsageLocation US

  .NOTES
  Switch the commented lines (circa line 57) to allow for user input.
  Requires "Connect-AzureAD" and "Connect-AzAccount -TenantId 'xxxxx'", with proper credentials, in order to be able to create a user if running locally.

#>

Param(
  [Parameter(Mandatory = $true)]
  [string]$FirstName,
  [Parameter(Mandatory = $true)]
  [string]$LastName,
  [Parameter(Mandatory = $true)]
  [string]$Email,
  [Parameter(Mandatory = $true)]
  [string]$UsageLocation
)


# login to AZAccount (Only if being run from a runbook)
<#
if (Get-Command -Name 'Get-AutomationConnection' -ErrorAction SilentlyContinue) {
  $azureADCredential = (Get-AutomationConnection -Name 'AzureRunAsConnection')
  Connect-AzAccount -Tenant $azureADCredential.TenantID -ApplicationID $azureADCredential.ApplicationID -CertificateThumbprint $azureADCredential.CertificateThumbprint -ServicePrincipal
}

## sending automated email to new user is in the Automation folder; see Password expiration.
#>

$userName = "$FirstName.$LastName@onmicrosoft.domain.com"
$fullName = $FirstName + " " + $LastName
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$TempPass = ([char[]](Get-Random -Input $(65..90) -count 6)) + ([char[]](Get-Random -Input $(33, 40, 41, 63, 45, 58, 59, 44, 94, 38) -count 6)) + ([char[]](Get-Random -Input $(48..57) -count 6)) + ([char[]](Get-Random -Input $(65..90) -count 6)) + ([char[]](Get-Random -Input $(97..122) -count 6)) -join ""

$PasswordProfile.Password = $TempPass

$azureaduserparams = @{
  DisplayName       = $fullName
  UserPrincipalName = $userName
  UserType          = "Member"
  OtherMails        = $Email
  MailNickName      = "${FirstName}.${LastName}"
  PasswordProfile   = $PasswordProfile
  Surname           = $LastName
  GivenName         = $FirstName
  UsageLocation     = $UsageLocation
  AccountEnabled    = $true
}

$azureUser = New-AzureADUser @azureaduserparams

#get the AAD Group ObjectID. Either manually supply, or run the following line to select on the fly.
#$aadGroupId = (Get-AzureADGroup | out-gridview -OutputMode Multiple).objectid
$aadGroupId = "xxxxx"
foreach ($group in $aadGroupId) {
  Add-AzureADGroupMember -ObjectId $group -RefObjectId $azureUser.objectid
}
