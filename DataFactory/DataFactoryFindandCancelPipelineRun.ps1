Get-AzDataFactoryV2 | Out-GridView -PassThru -OutVariable AzDataFactory
$DataFactory = $AzDataFactory.DataFactoryName
$RG = $AzDataFactory.ResourceGroupName
$before = Get-Date
$after = (Get-Date).AddDays(-2)

Get-AzDataFactoryV2PipelineRun -DataFactoryName $DataFactory -ResourceGroupName $RG -LastUpdatedAfter $after -LastUpdatedBefore $before | Format-Table -Property RunId, PipelineName, Status
