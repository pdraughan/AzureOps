# This command will identify what Zone and Location you will need.
# Get-AzComputeResourceSku | where {$_.ResourceType -eq "disks" -and $_.Name -eq "UltraSSD_LRS" }
#The zone is required during preview. 

$rgName = 'Resouce group Name'
$vmName = 'VM name'
$location = 'eastus2' 
$storageType = 'UltraSSD_LRS'
$dataDiskName = $vmName + '_disk1'


$diskConfig = New-AzDiskConfig -SkuName $storageType -Location $location -CreateOption Empty -DiskSizeGB 8192 -DiskIOPSReadWrite 160000 -DiskMBpsReadWrite 2000 -Zone 3
$dataDisk1 = New-AzDisk -DiskName $dataDiskName -Disk $diskConfig -ResourceGroupName $rgName

$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName 
$vm = Add-AzVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 1 

Update-AzVM -VM $vm -ResourceGroupName $rgName