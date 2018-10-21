$nodes = Get-ServiceFabricNode
foreach($node in $nodes)
{
    $replicas = Get-ServiceFabricDeployedReplica -NodeName $node.NodeName -ApplicationName "fabric:/Your-App"
    foreach ($replica in $replicas)
    {
        Remove-ServiceFabricReplica -ForceRemove -NodeName $node.NodeName -PartitionId $replica.Partitionid -ReplicaOrInstanceId $replica.ReplicaOrInstanceId
    }
}