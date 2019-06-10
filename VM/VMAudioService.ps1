#Connect to AD and Azure Portal Account. Left as two cmdlets without caching credentials due to current MFA limitation.
Connect-azuread
Connect-AzAccount
$subscriptionID = (Get-AzSubscription | ogv -PassThru).SubscriptionID
Set-AzContext -Subscription $subscriptionID

#Choose the VM
$VM = (Get-AzVm | ogv -Title "Choose the VM or VMs to which you wish to start the Audio Service" -OutputMode Multiple)
$VMResourceGroup = $vm.ResourceGroupName

#should one day make the Service selectable
$i = 0

foreach ($VirtualMachine in $VM)
{
Write-Progress -Activity "Starting Audio Service $VirtualMachine" -Status "Node $i of $($VM.Count) completed" -PercentComplete (($i / $VM.Count) * 100)
Set-Service 'Audiosrv' -StartupType Automatic
Start-Service -Name "Audiosrv"

$i = $i + 1
}
