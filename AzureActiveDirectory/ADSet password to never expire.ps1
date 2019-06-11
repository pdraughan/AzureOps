Connect-MsolService

set-MsolUser -UserPrincipalName Mdrx_Support_tasks@avenel.com -PasswordNeverExpires $true

Get-MsolUser -UserPrincipalName Mdrx-Support-tasks@avenel.com | Select *
