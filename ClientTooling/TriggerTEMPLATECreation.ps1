Param(
 [Parameter(Mandatory=$true)]
 [string]$FirstName,
 [Parameter(Mandatory=$true)]
 [string]$LastName,
  [Parameter(Mandatory=$true)]
 [string]$Email
)
# New-EventLog –LogName Application –Source "PowerShellCreateUser"
# ^ needs run in order to create new source.
#     ClientDrivenUserCreation - Runbook
$uri = "Runbook webhook address!"

switch ( Read-Host "From where will the user be accessing? Input 1 for United States, 2 for India" )
    {
        1 { $UsageLocation = "US"}
        2 { $UsageLocation = "IN"}
        default {Write-Host "Incorrect. Please try again."}
    }

# Assumes the VM running this script, has a managed identity, with proper rights to given resource.
Connect-AzAccount -Identity

    $user = ([Security.Principal.WindowsIdentity]::GetCurrent()).Name

# Modify the DepartmentFromPowerShell value to match the AzureAD Group (client number for our use)

$Parameters  = @{
                     Firstname=$FirstName
                     Lastname=$LastName
                     Email=$Email
                     DepartmentFromPowerShell="CHANGE ME!"
                     UsageLocation=$UsageLocation
                     user=$user
                }

$userName = "$FirstName.$LastName@xxxxxxxxx.com"

$body = ConvertTo-Json -InputObject $Parameters
$header = @{ message="$user"}
$response = Invoke-WebRequest -Method Post -Uri $uri -Body $body -Headers $header -UseBasicParsing
Write-Host "$FirstName.$LastName@xxxxxxx.com is being submitted for creation. Please wait." -ForegroundColor DarkCyan
$jobid = (ConvertFrom-Json ($response.Content)).jobids[0]

#job information needed to get status before proceeding
$RG = "defaultresourcegroup-eus"
$AutomationAccountName = "xxxxxxxx"


#do I add an exit in case the user isn't logged in?
$doLoop = $true
While ($doLoop) {
  $job = (Get-AzAutomationJob -ResourceGroupName $RG –AutomationAccountName $AutomationAccountName -Id $jobid)
  $status = $job.Status
  $doLoop = (($status -ne "Completed") -and ($status -ne "Failed") -and ($status -ne "Suspended") -and ($status -ne "Stopped"))
}

if ($job.Status -ne "Completed")
{
Write-Host "There was an error. Please try again or contact Support if the problem persists." -ForegroundColor DarkCyan
Write-EventLog -EventId 31337 -LogName "Application" -Message "$user failed to created $username via the Runbook job $jobid because of a reason referenced in that JobID" -Source "PowerShellCreateUser" -EntryType FailureAudit

}
else
{
Write-Host "User created Successfully. Please advise user to proceed to https://passwordreset.microsoftonline.com in order to complete registration" -ForegroundColor DarkCyan
Write-EventLog -EventId 31337 -LogName "Application" -Message "$user created $username via the Runbook job $jobid" -Source "PowerShellCreateUser" -EntryType SuccessAudit
}
Start-Sleep 15
exit