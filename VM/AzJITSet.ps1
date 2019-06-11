$subscriptionID = (Get-AzSubscription | Out-GridView -Title "Select the Azure Subscription in which the VM lives" -PassThru).SubscriptionId
Set-AzContext -Subscription $subscriptionID
# Select the Azure Resource Group and VM
$ResourceGroupName = (Get-AzResourceGroup | Out-GridView -Title "Select your Resource Group" -PassThru).ResourceGroupName
$VM = (Get-AzVM -ResourceGroupName $ResourceGroupName  | Out-GridView -Title "Select your Virtual Machine" -PassThru)
$VMName = $VM.Name
$VMID = $VM.Id
$VMLocation = $VM.Location


$JitPolicy = (@{
 id=$VMID
ports=(@{
     number=3389;
     protocol="*";
     allowedSourceAddressPrefix=@("*");
     maxRequestAccessDuration="PT3H"})})

$JitPolicyArr=@($JitPolicy)

Set-AzJitNetworkAccessPolicy -Kind "Basic" -Location "$VMLocation" -Name "default" -ResourceGroupName "$ResourceGroupName" -VirtualMachine $JitPolicyArr
