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
  Choose appropriate Country code for the users primary location (typically US or IN)

  .EXAMPLE
  ./create_AAD_workflow.ps1 -FirstName Special -LastName Person -Email 8chars@email.com -UsageLocation US

  .NOTES
  AAD group addition at time of creation is commented out and a hard coded value or user input at time of creation, is available at the bottom of the script.
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

$userName = "$FirstName.$LastName@aad.io"
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
<#
#get the AAD Group ObjectID. Either manually supply, or run the following line to select on the fly.
#>
$aadGroup = Get-AzureADGroup -All $true | out-gridview -OutputMode Multiple

# $aadGroupId = "xxx"
foreach ($group in $aadGroup) {
  Add-AzureADGroupMember -ObjectId $group.ObjectID -RefObjectId $azureUser.objectid
}
$person = Get-AzContext 
$now = Get-Date
Write-Host "$($person.Account.ID)Successfully created $username at $now" -ForegroundColor Green
Write-Host "Added $username to $($aadGroup.DisplayName)" -ForegroundColor Green