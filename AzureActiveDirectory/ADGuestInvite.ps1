Param(
 [Parameter(Mandatory=$true)]
 [string]$FirstName,
 [Parameter(Mandatory=$true)]
 [string]$LastName,
  [Parameter(Mandatory=$true)]
 [string]$Email
 )

connect-azuread
# assumes user will not need invitation or link, and will go to https://portal.azure.com/avenel.com on their own.
New-AzureADMSInvitation -InvitedUserEmailAddress "$Email" -InvitedUserDisplayName "$FirstName $LastName" -InviteRedirectUrl https://portal.azure.com/avenel.com -SendInvitationMessage $false | Out-Null