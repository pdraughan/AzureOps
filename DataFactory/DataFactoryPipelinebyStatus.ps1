Get-AzDataFactoryV2 | Out-GridView -PassThru -OutVariable AzDataFactory

$allPipeRuns = (Get-AzDataFactoryV2PipelineRun -LastUpdatedAfter "04/07/2019, 11:22:56 PM" -LastUpdatedBefore "04/08/2019, 11:22:56 PM" -ResourceGroupName $AzDataFactory.ResourceGroupName -DataFactoryName $AzDataFactory.DataFactoryName)

foreach ($PipeRun in $allPipeRuns)
{
If ($PipeRun.status -eq "Cancelled")
{
Write-Host $PipeRun.RunId
}
Else
{ Out-Null}
}