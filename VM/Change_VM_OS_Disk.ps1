# Change the OS Disk of a VM

# Find the disk name that you want to add.
Get-AzDisk -ResourceGroupName myResourceGroup | Format-Table -Property Name


# Get the VM 
$vm = Get-AzVM -ResourceGroupName myResourceGroup -Name myVMName

# Make sure the VM is stopped\deallocated
Stop-AzVM -ResourceGroupName myResourceGroup -Name $vm.Name -Force

# Get the new disk that you want to swap in
$disk = Get-AzDisk -ResourceGroupName myResourceGroup -Name MyDisktoUse

# Set the VM configuration to point to the new disk  
Set-AzVMOSDisk -VM $vm -ManagedDiskId $disk.Id -Name $disk.Name 

# Update the VM with the new OS disk
Update-AzVM -ResourceGroupName myResourceGroup -VM $vm 

# Start the VM
Start-AzVM -Name $vm.Name -ResourceGroupName myResourceGroup


