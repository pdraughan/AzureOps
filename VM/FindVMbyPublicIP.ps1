$IP = Read-Host "Enter the PublicIP of the Virtual Machine you wish to find"
$i = 0
$subs = Get-AzSubscription 
foreach ($Sub in $Subs) { 
    $SelectSub = Select-AzSubscription -SubscriptionName $Sub.Name 

$RG = Get-AzResourceGroup 
        Write-Progress -Activity "Searching Subscriptions" -Status "Subscription $i of $($subs.Count) completed" -PercentComplete (($i / $subs.Count) * 100)
                $i = $i + 1

    foreach ($Group in $RG) {
        $PublicIP = (Get-AzPublicIpAddress -ResourceGroupName $group.ResourceGroupName | ?{$_.IpAddress -eq $IP})
    if($PublicIP -eq $null) 
        {
        Out-Null

        }
    else
        {
        Write-Host "PublicIP resource is named"$PublicIP.Name", found in ResourceGroup"$PublicIP.ResourceGroupName"" -ForegroundColor Cyan
        Write-Host "Done searching. Above is your answer, but if it isn't there... then the VM isn't on, or it isn't ours." -ForegroundColor Green
        exit
        }
    } 
}

