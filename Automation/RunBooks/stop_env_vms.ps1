<#
.SYNOPSIS
  Connects to Azure and stops of all VMs in the chosen environment. Works magnificently well if you add a Flow to Teams, that will then accept user input (via a dropdown), to allow persons to select the environment/set they want to shutdown.

.DESCRIPTION
  This runbook connects to Azure and stops all VMs in any resource group that is like the chosen environment name.

.PARAMETER Environment
RGs containing the input environment will be chosen for the action.
.PARAMETER SubID
subscriptionID contexted needed for this runbook, where the VMs and KeyVault are loacted.
#>

param
(
    [Parameter (Mandatory = $true)]
    [string] $Environment,
    [Parameter (Mandatory = $true)]
    [string] $subID = 'Subscription GUID goes here'
)

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Connect-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

function jobwait {
    $jobs = (get-job).State
    while ($jobs -eq "Running") {
        start-sleep -Seconds 15
        $jobs = (Get-Job).State | Select-Object -Last 1 
        write-host $jobs
    }

    if ($jobs -eq "Completed") {
        #write-output "$($Environment) has begun"
        Write-Output "Stage Completed"
    }

    else {
        write-output "Something went wrong."
    }
}

# set context to desired Subscription; below is Dev
set-azcontext -subscriptionID $subID | Out-Null
$wildenvironment = "*$Environment*"
#get all resource groups for the environment
$ResourceGroupNames = (Get-AzResourceGroup | Where-Object ResourceGroupName -Like "$wildenvironment").ResourceGroupName

$DBs = @()
$TheRest = @()

foreach ($rg in $ResourceGroupNames) {
    if ($rg -Like "*db*") {
        $DBs += Get-AzVM -ResourceGroupName $rg
    }
    else {
        $TheRest += Get-AzVM -ResourceGroupName $rg
    }
}

foreach ($remainingvm in $TheRest) {
    $remainingvm | stop-AzVM -Force -ErrorAction Continue -AsJob
    #write-host "$($remainingvm.Name) as a remnant"
}
# wait until the above completes before completing
jobwait

foreach ($db in $DBs) {
    $db | stop-AzVM -Force -ErrorAction Continue -AsJob
    #write-host "$($db.Name) as a DB"
}
# wait until the above completes before progressing
jobwait

