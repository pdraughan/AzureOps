$IP = Read-Host "Enter the PrivateIP of the Virtual Machine you wish to find"

$subscriptionID = (Get-AzSubscription).SubscriptionID

foreach ($sub in $subscriptionID)
{
Set-AzContext -Subscription $sub | Out-Null
$a = ((Get-AzNetworkInterface | ?{$_.IpConfigurations.PrivateIpAddress -eq $IP}).VirtualMachine).ID
$vmname = ($a -split '/') | select -Last 1
Write-Host "$vmname" -ForegroundColor Cyan
}
Write-Host "Done searching. Above is your answer" -ForegroundColor Cyan