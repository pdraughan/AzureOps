<#
  .DESCRIPTION 
  Uses Azure Automation Account's RunAs Account, with User Administrator or higher, to scan for any passwords expiring within the configuration number of days.


  .PARAMETER daysExpire
  The number of days for which you want to alert.

  .EXAMPLE
  ./ADGet_passwords_about_to_expire.ps1 -daysExpire 90

  .NOTES
User must have User Administrator or greater in order to get
#>

Param(
  [Parameter(Mandatory = $true)]
  [number]$daysExpire
)

# Retrieve credential from Automation asset store and authenticate to Azure AD
$AzureADCredential = Get-AutomationPSCredential -Name "AzureADCredential"
Connect-MsolService -Credential $AzureADCredential

# Get default domain to work against
$DefaultDomain = Get-MsolDomain | Where-Object {$_.IsDefault -eq $true} 

# Retrieve password policy
$PasswordPolicy =  New-TimeSpan -Days $daysExpire

# Get all users in Azure AD
    $ADUsers = Get-MsolUser -All | Where-Object {($_.UserType -eq "Member") -and ($_.PasswordNeverExpires -ne $true) -and ($_.LastPasswordChangeTimestamp -lt [DateTime]::Today.AddDays(-76))} 

    #$ADUsers
    $Users = @()

foreach ($ADUser in $ADUsers)
{
    # Identify when the password was last changed
    $LastChanged = $ADUser.LastPasswordChangeTimestamp

    # Get the days since the last time the password was changed.
    $DaysSinceLastChanged = New-TimeSpan -Start (Get-Date) -End $LastChanged

    # Get list of all users and when their password expires
    $DaysLeft = ($DaysSinceLastChanged.Days + $daysExpire)

        $Users += New-Object psobject -Property @{
                   ObjectID = $ADUser.ObjectId
                   UserDisplayName = $ADUser.DisplayName
                   UserPrincipalName = $ADUser.UserPrincipalName
                   AlternateEmailAddresses = $ADUser.AlternateEmailAddresses
                   PasswordLastChanged = $LastChanged
                   DaysLeft  = $DaysLeft
               }
   
} 
 

#Convert to Json, so that it is in a workable format in the logic app.
Write-Output $Users | Out-GridView

# ConvertTo-Json