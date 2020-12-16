# JIT Powershell
Use the following in a PowerSHell RemoteApp presentend via RDS for a remote tool by which user can request access to a Public IP for RDP, from their IP, for a limited amount of time.

```
# sign in, to determine by which rights you can access Azure resources
Connect-AzAccount

#choose the VM you wish to access
$subscriptionID = (Get-AzSubscription | Out-GridView -Title "Select the Azure Subscription in which the VM lives" -PassThru).SubscriptionId
Set-AzContext -Subscription $subscriptionID
$ResourceGroupName = (Get-AzResourceGroup | Out-GridView -Title "Select your Resource Group" -PassThru).ResourceGroupName
$VM = (Get-AzVM -ResourceGroupName $ResourceGroupName  | Out-GridView -Title "Select your Virtual Machine" -PassThru)
$VMName = $VM.Name
$VMID = $VM.Id
$VMLocation = $VM.Location

switch  (Read-Host "Enter the number of hours to open port 3389 on VM $VMName. 1-3 is allowed.") {

  '1' {$hours="1"}
  '2' {$hours="2"}
  '3' {$hours="3"}
  default {$hours="2"}
}

#IP address of the Jumpbox from which this script is hosted, OR, use commented lines below for PublicIP retrieval
$ip = "10.0.75.1"
# Use the following line instead of 10.x.x.x if running locally and not from a static jumpBox with private IP
## $ip = (Invoke-RestMethod http://ipinfo.io/json | Select -exp ip)

#time
$now = Get-Date
$EndTime = $now.addHours($hours)

# Putting it all together to  request Access
$JitPolicyVm1 = (@{
  id=$VMID
ports=(@{
   number=3389;
   endTimeUtc=$endtime;
   allowedSourceAddressPrefix=$ip
   })})


$JitPolicyArr=@($JitPolicyVm1)

Start-AzJitNetworkAccessPolicy -ResourceId "/subscriptions/$subscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Security/locations/$VMLocation/jitNetworkAccessPolicies/default" -VirtualMachine $JitPolicyArr

Write-Host "$VMName is now available for $hours hours from $ip ONLY" -ForegroundColor DarkMagenta

#Start-Sleep 15
#Exit
```
