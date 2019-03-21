Function Remove-AzVMInstanceParallel {
[cmdletbinding(SupportsShouldProcess,ConfirmImpact='High')]
 Param (
    [parameter(mandatory)]
    [String]$ResourceGroup,
    
    # The VM name to remove, regex are supported
    [parameter(mandatory)]
    [String]$VMName,

    # The Script will not wait for the background jobs by default, use this switch to wait
    [Switch]$Wait
 )

    # Remove the VM's and then remove the datadisks, osdisk, NICs
$jobs = Get-AzVM -ResourceGroupName $ResourceGroup | Where Name -Match $VMName  | foreach {
        $vm=$_
        
        # avoid locks on the tokencache.dat file
        Start-Sleep -Seconds 3

        Start-Job -ScriptBlock {
            
            Try {
                $ctx = Import-AzContext -path $home\ctx.json -ErrorAction Stop
                
                $resourceGroup = $using:Resourcegroup
                $VMName = $using:VM
                # $ctx
                # Get-AzResourceGroup -Name $resourceGroup
         
                Write-Verbose -Message "Connected to $($ctx.Context.Subscription.Name)" -Verbose
                Write-Verbose -Message "The following resources were found:"
       

                $VM = Get-AzVM -ResourceGroupName $resourceGroup -Name $VMName.Name -Verbose
        
                $DataDisks = @($VM.StorageProfile.DataDisks.Name)
                $OSDisk = @($VM.StorageProfile.OSDisk.Name)
                $NICS = @($VM.NetworkProfile.NetworkInterfaces)
                $ManagedDisk = $VM.StorageProfile.OsDisk.ManagedDisk
                ($OSDisk + $DataDisks)
                $NICS | Foreach ID

                # Remove confirm preference for background jobs
                #if ($pscmdlet.ShouldProcess("$($VM.Name)", "Removing VM, Disks and NIC: $($VM.Name)"))
                #{
                    Write-Warning -Message "Deleting VM:[$($VMName.Name)] from RG:[$resourceGroup]"
        
                    #DELETE Virtual Machine
                    $VM | Remove-AzVM -Force -Confirm:$false

                    #DELETE NIC
                    $NICS | ForEach-Object {
                        $NICName=split-path $_.ID -leaf
                        Write-Warning -Message "Removing NIC: $NICName"
                        Get-AzNetworkInterface -ResourceGroupName $ResourceGroup -Name $NICName | Remove-AzNetworkInterface -Force       
                    }

                    if($ManagedDisk) {
                        #DELETE MANAGEDDISKS
                       ($OSDisk + $DataDisks) | ForEach-Object {
                            Write-Warning -Message "Removing Disk: $_"
                            Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $_ | Remove-AzDisk -Force
                        }
                    }
                    else {
                        #DELETE DATA DISKS 
                        $saname = ($VM.StorageProfile.OsDisk.Vhd.Uri -split '\.' | Select -First 1) -split '//' |  Select -Last 1
        
                        $SA = Get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $saname
                        $VM.StorageProfile.DataDisks | foreach {
                            $disk = $_.Vhd.Uri | Split-Path -Leaf
                            Get-AzureStorageContainer -Name vhds -Context $Sa.Context |
                            Get-AzureStorageBlob -Blob  $disk |
                            Remove-AzureStorageBlob  
                        }

                        #DELETE OS DISKS
                        $saname = ($VM.StorageProfile.OsDisk.Vhd.Uri -split '\.' | Select -First 1) -split '//' |  Select -Last 1
                        $disk = $VM.StorageProfile.OsDisk.Vhd.Uri | Split-Path -Leaf
                        $SA = Get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $saname
                        Get-AzureStorageContainer -Name vhds -Context $Sa.Context |
                        Get-AzureStorageBlob -Blob  $disk |
                        Remove-AzureStorageBlob  

                    }
            
                    # If you are on the network you can cleanup the Computer Account in AD            
                    # Get-ADComputer -Identity $a.OSProfile.ComputerName | Remove-ADObject -Recursive -confirm:$false
                
                # remove confirm preference for background jobs
                #}#PSCmdlet(ShouldProcess)
            }
            Catch {
                Write-Warning -Message 'You must save your Context first [Save-AzContext -Path $home\ctx.json -Force]'
                Write-Warning $_
            }#Catch
            }#Start-Job
    }#Foreach-Object(Get-AzVM)
sleep -Seconds 30
$jobs | Receive-Job -Keep

if ($Wait)
{
    sleep -Seconds 30
    $jobs | Wait-Job | Receive-Job
}
else
{
    Write-Warning "Run the following to view status of parallel delete`nGet-Job | Receive-Job -Keep"
}
}#Function