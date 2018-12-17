[CmdletBinding()]
param
(
[parameter(Mandatory=$true)]
[string]$ApplicationName,
[parameter(Mandatory=$true)]
[string]$ServiceName
)
# Must first be connected to a SF cluster. Then update $applicationName and $serviceName to desired values
$nodes = (Get-ServiceFabricNode).NodeName
$i = 0

foreach ($node in $nodes)
{
Write-Progress -Activity "Restarting Code Packages on $node" -Status "Node $i of $($nodes.Count) completed thus far" -PercentComplete (($i/$nodes.Count)*100)  

Restart-ServiceFabricDeployedCodePackage -ApplicationName $ApplicationName -ServiceName $ServiceName -CommandCompletionMode Verify
Write-Host "$ServiceName is restarting on the above node and will proceed to the next node in 30 seconds" -ForegroundColor DarkCyan
#Start-Sleep -Seconds 30
$i = $i + 1
}

Write-Host "The code packages for $ServiceName has been restarted on all nodes" -ForegroundColor Cyan
