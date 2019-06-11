# assumes connection to a SF Cluster
# Choose ONE Application > Service. Can choose multiple partitions and replicas

$SFApplication = (Get-ServiceFabricApplication | Select-Object ApplicationName, ApplicationTypeVersion, ApplicationStatus, HealthState | ogv -PassThru)
$SFService = (Get-ServiceFabricService -ApplicationName $SFApplication.ApplicationName | ogv -PassThru).ServiceName.AbsoluteUri
$SFPartitionID = ((Get-ServiceFabricPartition -ServiceName $SFService).PartitionID | ogv -OutputMode Multiple)

foreach ($Partition in $SFPartitionID)
{
$ReplicaToRemove = (Get-ServiceFabricReplica -PartitionId $Partition | ogv -PassThru).ReplicaId
    
    foreach ($replica in $ReplicaToRemove)
    {
    Remove-ServiceFabricReplica -PartitionId $Partition -ServiceName $SFService -ReplicaOrInstanceId $replica -ForceRemove
    }

}
