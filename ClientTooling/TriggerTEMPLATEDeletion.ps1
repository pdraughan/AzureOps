Param(
 [Parameter(Mandatory=$true)]
 [string]$username
)
# New-EventLog –LogName Application –Source "PowerShellDeleteUser"
# ^ needs run in order to create new source.
#     ClientDrivenUserDeletion - Runbook

$uri = "Runbook webhook address!"
$user = ([Security.Principal.WindowsIdentity]::GetCurrent()).Name


# Assumes the VM running this script, has a managed identity, with proper rights to given resource.
Connect-AzAccount -Identity

# DepartmentfromPowershell needs to be the Client's AD Group's ObjectID, for which this PowerShell is written# DepartmentfromPowershell needs to be the Client's AD Group's ObjectID, for which this PowerShell is written

$Parameters  = @{
                     Username=$username
                     DepartmentFromPowerShell="Declare your own!"
                     user=$user
                }


$body = ConvertTo-Json -InputObject $Parameters
$header = @{ message="$user"}
$response = Invoke-WebRequest -Method Post -Uri $uri -Body $body -Headers $header -UseBasicParsing
$jobid = (ConvertFrom-Json ($response.Content)).jobids[0]

$RG = "defaultresourcegroup-eus"
$AutomationAccountName = "xxxxxxxx"

Write-Host "$username is being submitted for deletion. Please wait." -ForegroundColor DarkCyan

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
Write-EventLog -EventId 31337 -LogName "Application" -Message "$user attempted to delete $username via the Runbook job $jobid, but failed" -Source "PowerShellDeleteUser" -EntryType FailureAudit

}
else
{
Write-Host "$username has been deleted and no longer has access to Azure resources." -ForegroundColor DarkCyan
Write-EventLog -EventId 31337 -LogName "Application" -Message "$user deleted $username via the Runbook job $jobid" -Source "PowerShellDeleteUser" -EntryType SuccessAudit
}
Start-Sleep 15
exit