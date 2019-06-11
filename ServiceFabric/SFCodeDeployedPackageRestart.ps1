$SFApplication = $null
# Must first be connected to a SF cluster. Then update $applicationName and $serviceName to desired values
$SFApplication = (Get-ServiceFabricApplication | Select-Object ApplicationName, ApplicationTypeVersion, ApplicationStatus, HealthState | ogv -PassThru)
$SFService = (Get-ServiceFabricService -ApplicationName $SFApplication.ApplicationName | ogv -PassThru)
$SFPartitionID = (Get-ServiceFabricPartition -ServiceName $SFService.ServiceName).PartitionID

#prevents previous context tainting the script
$Nodes = $null
$i=0

#Checks through each Partition's replicas to collect all nodes upon which the service is installed
foreach ($PartitionID in $SFPartitionID)
{
$5Nodes = (Get-ServiceFabricReplica -PartitionId $PartitionID).NodeName
$Nodes = ($5Nodes + $Nodes | Select-Object -Unique)
}

#checks one Node for the different manifests to ensure we're restarting the correct service
$FirstNode = ($Nodes | Select-Object -First 1)
$ServiceManifestName = (Get-ServiceFabricDeployedCodePackage -ApplicationName $SFApplication.ApplicationName -NodeName $FirstNode | Select-Object ServiceManifestName | ogv -PassThru).ServiceManifestName

#restart each service codepackage on a given node
foreach ($node in $Nodes)
{
Write-Progress -Activity "Restarting Code Packages on $node" -Status "Node $i of $($Nodes.Count) completed" -PercentComplete (($i / $Nodes.Count) * 100)
$codepackageinfo = (Get-ServiceFabricDeployedCodePackage -ApplicationName $SFApplication.ApplicationName -NodeName $node -ServiceManifestName $ServiceManifestName)
try{
Restart-ServiceFabricDeployedCodePackage -NodeName $node -ApplicationName $SFApplication.ApplicationName -ServiceManifestName $ServiceManifestName -CodePackageName $codepackageinfo.CodePackageName -ServicePackageActivationId $codepackageinfo.ServicePackageActivationId -CommandCompletionMode Verify | Out-Null
}
catch {}
Write-Host "$SFService.ServiceName is restarting on $node and will proceed to the next node in 15 seconds" -ForegroundColor DarkCyan
Start-Sleep -Seconds 10
$i = $i + 1
}
Write-Host "The code packages for $ServiceName has been restarted on all nodes that host the DeployedCodePackages" -ForegroundColor Cyan