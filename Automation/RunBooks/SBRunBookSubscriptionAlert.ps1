<#
  .DESCRIPTION 
  As the AA RunAs Account, reads designated ServiceBus for topic subscriber counts and writes alertable words, that can be set to be monitored by an Alert. Match criteria must be manually defined.


  .PARAMETER SubscriptionID
  Subscription ID where the service bus is located.  
  .PARAMETER RG
  Resource Group where the service bus is located.
  .PARAMETER NameSpace
  Name of the Service Bus.

  .EXAMPLE
  ./SBRunBookSubscriptionAlert.ps1 -subscriptionID 1234-1234-23 -RG "Resource Group" -NameSpace "ServiceBus Namespace"

#>

Param(
  [Parameter(Mandatory = $true)]
  [string]$SubscriptionID,
  [Parameter(Mandatory = $true)]
  [string]$RG,
  [Parameter(Mandatory = $true)]
  [string]$NameSpace
)

$cred = Get-AutomationPSCredential -Name 'xxxx'
Connect-AzAccount -Credential $cred | Out-Null

Set-AzContext -Subscription $SubscriptionID | Out-Null
Get-AzServiceBusTopic -ResourceGroupName $RG -Namespace $NameSpace | Select-Object Name, SubscriptionCount -OutVariable Topics | Out-Null

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