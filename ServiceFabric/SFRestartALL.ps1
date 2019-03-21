$apps = Get-ServiceFabricApplication
foreach($a in $apps)
{
    $services = Get-ServiceFabricService -ApplicationName $a.ApplicationName | where-object ServiceTypeName -ne "AuditLoggingServiceType"
    foreach($s in $services)
    {
        $partitions = Get-ServiceFabricPartition -ServiceName $s.ServiceName
        foreach($p in $partitions)
        {
            $replicas = Get-ServiceFabricReplica -PartitionId $p.PartitionId
            foreach($r in $replicas)
            {
                (Restart-ServiceFabricDeployedCodePackage -ApplicationName $A.ApplicationName.OriginalString -PartitionId $p.PartitionId -ReplicaOrInstanceId $r.InstanceId -ServiceName $s.ServiceName -ErrorAction SilentlyContinue)
                Start-Sleep 5;
            }
        }
    }
}