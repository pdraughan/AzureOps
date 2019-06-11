Get-AzServiceBusNamespace | ogv -PassThru -OutVariable ServiceBus
$RG = $ServiceBus.ResourceGroup
$NameSpace = $ServiceBus.Name
Get-AzServiceBusTopic -ResourceGroupName $RG -Namespace $NameSpace | Select-Object Name, SubscriptionCount -OutVariable Topics

$ScriptPadTopics = $Topics | Where-Object {$_.Name -Like "healthcare.scriptpad*"}

foreach ($topic in $ScriptPadTopics)
{
If ($topic.SubscriptionCount -eq 0)
    {
    Write-Host "ALERT! Subscription Count for"$topic.Name"is at zero"
    }
Else
    {
   Out-Null
    }
}