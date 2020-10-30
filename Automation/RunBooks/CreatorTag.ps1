<#
  .DESCRIPTION 
    Template for a runbook that should be set to a regular interval schedule; scans available resources and if a "Creator" tag does not exist,
    one is created for the resource, given the value of the oldest audit "write" record on that Azure Resource.

  .NOTES
    State the criteria by which the $person should be sought (line 25). Typically username@domain.com is sufficient.
#>

# login to AZAccount (Only if being run from a runbook)
<#
  $azureADCredential = (Get-AutomationConnection -Name 'AzureRunAsConnection')
  Connect-AzAccount -Tenant $azureADCredential.TenantID -ApplicationID $azureADCredential.ApplicationID -CertificateThumbprint $azureADCredential.CertificateThumbprint -ServicePrincipal
#>

$subscriptionID = (Get-AzSubscription).SubscriptionID

foreach ($sub in $subscriptionID) {
    Set-AzContext -SubscriptionID $sub | Out-Null

    $AllTheResources = Get-AzResource -OutVariable AllTheResources | Out-Null

    foreach ($thing in $AllTheResources) {
        if ($thing.Tags.Keys -notcontains "Creator") {
            $person = (Get-AzLog -ResourceId $thing.ResourceId -StartTime (Get-Date).AddDays(-89) | Where-Object { $_.OperationName.Value -like "*/write" } | Where-Object { $_.Caller -like "*@domain.com" } | Select caller, EventTimestamp | Sort-Object -Property EventTimestamp | Select-Object caller -First 1).Caller
            if ($person -ne $null) {
                if ($thing.Tags -eq $null) {
                    $name = $thing.Name
                    $r = Get-AzResource -ResourceName $name -ResourceGroupName $thing.ResourceGroupName
                    $tagvalue = @{Creator = "$person" }
                    Set-AzResource -ResourceId $r.ResourceId -Tag $tagvalue -Force
                }
                else {
                    $name = $thing.Name
                    $r = Get-AzResource -ResourceName $name -ResourceGroupName $thing.ResourceGroupName
                    $r.Tags.Add("Creator", "$person")
                    Set-AzResource -Tag $r.Tags -ResourceId $r.ResourceId -Force
                }
            }        
        }
    }
}