$ServiceName = 'fabric:/ServiceName'
$partitions = Get-ServiceFabricPartition -ServiceName $ServiceName
$partitions | Foreach-Object { Restart-ServiceFabricReplica -PartitionId $_.PartitionId -ServiceName $ServiceName -ReplicaKindPrimary }