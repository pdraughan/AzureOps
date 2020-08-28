<#
.SYNOPSIS
  Get all VMs in a given environment, create a new local Admin password, put it into a kv, and reset all VMs' local Admin users, in the environment scope, to the new password.

.PARAMETER Environment
State environment(s) affected by this runbook.

.PARAMETER SubID
subscriptionID contexted needed for this runbook, where the VMs and KeyVault are loacted.

.PARAMETER username
The name of the Local Admin to be created/reset and placed in KeyVault.
#>

param
(
    [Parameter (Mandatory = $true)]
    [string] $Environment = 'dv01',
    [Parameter (Mandatory = $true)]
    [string] $subID = 'Subscription GUID goes here'

)

$connectionName = "AzureRunAsConnection"
try {
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Connect-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null
}
catch {
    if (!$servicePrincipalConnection) {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    }
    else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

# set context to desired Subscription; below is Dev
set-azcontext -subscriptionID $subID | Out-Null

$userName = "SuperUsername"
foreach ($env in $Environment) {
    get-azvm | Where-Object Name -like "*$env*" -OutVariable EnvVMs
    try {
        $pwd = ([char[]](Get-Random -Input $(65..90) -count 6)) + ([char[]](Get-Random -Input $(33, 40, 41, 63, 45, 58, 59, 44, 94, 38) -count 6)) + ([char[]](Get-Random -Input $(48..57) -count 6)) + ([char[]](Get-Random -Input $(65..90) -count 6)) + ([char[]](Get-Random -Input $(97..122) -count 6)) -join ""
        $secretpwd = $(ConvertTo-SecureString $pwd -AsPlainText -Force)

        $null = Set-AzKeyVaultSecret -VaultName "kv-$env" -Name $userName -SecretValue $secretpwd -ContentType $userName
        $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, $secretpwd
        
        Write-Output "New password added to the KeyVault for $($env)."
    }
    catch {
        Write-Output "Password and KeyVault failure $($env). Please review. Error 12345"
    }
    foreach ($vm in $EnvVMs) {
        try {
            Set-AzVMAccessExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Credential $credential -typeHandlerVersion "2.4" -Name VMAccessAgent -ForceRerun $true
            Write-Output "$($vm.Name) successfully updated with new local admin password."
        }
        catch {
            Write-Output "$($vm.Name) experienced failure and needs to be investigated. Error 12345"
        }
    }
}