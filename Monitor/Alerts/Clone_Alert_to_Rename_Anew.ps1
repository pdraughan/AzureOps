<#
  .DESCRIPTION 
    Allows the user to select an existing Log Analytics query alert, to clone it with the same everything, but setting a new name;
    Effectively, renaming the alert, and disabling the original.

  .NOTES
  Has not been tested since 2018 and likely needs improvement, but I'm leaving it here for thought template purposes.
#>


Get-AzSubscription | Out-GridView -PassThru | Set-AzContext | Out-Null
Get-AzResourceGroup | Out-GridView -PassThru -OutVariable RG
$rule = @()
$AlertRules = @()

$groupname = $rg.ResourceGroupName

Get-AzResource -ResourceGroupName $groupname -ResourceType microsoft.insights/metricalerts -OutVariable names | Out-Null
foreach ($name in $names) {

    Get-AzResource -ResourceGroupName $groupname -Name $name.Name -ResourceType microsoft.insights/metricalerts -OutVariable rule #| Out-Null
    # Get-AzScheduledQueryRule -ResourceGroupName $group -Name $name.Name -OutVariable rule
    $AlertRules += New-Object psobject -Property @{
        Name        = $rule.Name
        DisplayName = $rule.Properties.DisplayName
        Description = $rule.Properties.description
    }

}

function doChanges {
$AlertRules | Out-GridView -Title "Select ONE Rule you wish to clone so that you can rename" -PassThru -outvariable CloneHost
$displayname = $CloneHost.Displayname
Write-Host "$displayname"

$NewNameRule = (Read-Host "What new name do you seek for the selected rule?")

Get-AzScheduledQueryRule -Name $CloneHost.Name -ResourceGroupName $groupname -OutVariable Query | Out-Null
Get-AzMetricAlertRuleV2 -
New-AzScheduledQueryRule -Action $Query.Action -Enabled $true -Location $Query.Location -Name $NewNameRule -ResourceGroupName $groupname -Schedule $Query.Schedule -Source $Query.Source -Description $Query.Description
New-AzMetricAlertRuleV2Criteria
New-AzMetricAlertRuleV2DimensionSelection
    <#
    "Remove" only works for rules created since June 1, 2019 or older rules that have been converted.

    $response = (Read-Host "Do you want to delete the original Rule? [Y] or [N]")
    if ($response = "Y") {
        Remove-AzScheduledQueryRule -Name $CloneHost.Name -ResourceGroupName $groupname
    }
# use the below if you prefer disable over delete; still must be a new API-based rule
    Update-AzScheduledQueryRule -Enabled $false -Name $clonehost.Name -ResourceGroupName $groupname
#>

Write-Host "Congratulations! You've successfully cloned "$CloneHost.Displayname" and made a new rule named "$NewNameRule" " -ForegroundColor Green
}

do {doChanges
$again = (Read-Host "Rename another rule in the same RG? [Y} or [N]"])
} until ($again -eq "N")