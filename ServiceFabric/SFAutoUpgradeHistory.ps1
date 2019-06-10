Param(
 [Parameter(Mandatory=$true)]
 [string]$ResourceGroupName,
 [Parameter(Mandatory=$true)]
 [string]$VMScaleSetName
)

Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VMScaleSetName -OSUpgradeHistory