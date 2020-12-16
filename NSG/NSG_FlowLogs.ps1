<#
  .DESCRIPTION 
    Sets all NSGs within a region and subscription, to store their NSG Flow logs (V2) into a chosen Storage Account, with a configurable retention period.

  .PARAMETER retentionperiod
    Acceptable values are 0-360. Numbers equate to number of days logs will be retained.

  .EXAMPLE
  ./NSG_FlowLogs.ps1 -retentionperiod 30

#>

Param(
  [Parameter(Mandatory = $true)]
  [string]$retentionperiod
)

Get-AzSubscription | ogv -PassThru -Title "Choose the subscription containing the target storage account" | Set-AzContext
$storageAccount = Get-AzStorageAccount | ogv -PassThru -Title "Choose an existing STorage account into which the NSG Logs Container will be placed"
$nw = Get-AzNetworkWatcher | ? {$_.Name -match "east"}
$retentionperiod = "30"
$nsgs = Get-AzNetworkSecurityGroup

Foreach($nsg in $nsgs)
    {
    Set-AzNetworkWatcherConfigFlowLog -NetworkWatcher $NW -TargetResourceId $nsg.Id -StorageAccountId $storageAccount.Id -EnableFlowLog $true -EnableRetention $true -RetentionInDays $retentionperiod -FormatVersion 2 -FormatType Json
    write-host "Diagnostics enabled for $nsg.Name " -BackgroundColor Green
    }