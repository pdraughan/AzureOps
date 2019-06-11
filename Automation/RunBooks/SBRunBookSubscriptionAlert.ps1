$cred = Get-AutomationPSCredential -Name 'xxxx'
Connect-AzAccount -Credential $cred | Out-Null

Set-AzContext -Subscription "xxxxxx" | Out-Null
Get-AzServiceBusTopic -ResourceGroupName "xxxxxx" -Namespace "xxxxx" | Select-Object Name, SubscriptionCount -OutVariable Topics | Out-Null

$ScriptPadTopics = $Topics | Where-Object {($_.Name -Like "xxxxxx*") -and ($_.Name -ne "xxxx~something")}
$Topics

foreach ($topic in $ScriptPadTopics)
{
If ($topic.SubscriptionCount -eq 0)
    {
     $alert = ("ALERT! Subscription Count for $topic is at zero")
    Write-OutPut $alert
    }
Else
    {
   Out-Null
    }
}