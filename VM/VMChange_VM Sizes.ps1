#Import Servers textfile          
$computers = Get-Content C:\Scripts\odd_RDS.txt
 
$resourceGroup = "RGName"
         
foreach ($computer in $computers) {            
  
Stop-AzVM -ResourceGroupName $resourceGroup -Name $computer -Force
$vm = Get-AzVM -ResourceGroupName $resourceGroup -VMName $computer
$vm.HardwareProfile.VmSize = "Standard_D4s_v3"
#$vm.HardwareProfile.VmSize = "Standard_D8s_v3"
Update-AzVM -VM $vm -ResourceGroupName $resourceGroup
Start-AzVM -ResourceGroupName $resourceGroup -Name $computer 

}