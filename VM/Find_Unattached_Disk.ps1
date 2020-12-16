$Sub = Get-AzSubscription

foreach ($one in $Sub){

$Ses = $one.name
$path = "C:\Scripts\$ses.csv"
Select-AzSubscription -Subscription $one.ID 
Get-AzDisk | Where-Object {$_.ManagedBy -eq $Null} | Select-object Name, ResourceGroupName, DiskSizeGB | Export-CSV -Path $Path -UseCulture -Encoding ascii -NoTypeInformation

}


# If you want to export to a single file

#  $Sub = Get-AzSubscription
#  $Date = Get-Date -Format dd_MMMM_yyyy
#  foreach ($one in $Sub){

#  $path = "C:\Scripts\Unattached_Disks.csv"
#  Select-AzSubscription -Subscription $one.ID 
#  Get-AzDisk | Where-Object {$_.ManagedBy -eq $Null} | Select-object Name, ResourceGroupName, DiskSizeGB | Export-CSV -Path $Path -UseCulture -Encoding ascii -NoTypeInformation -Append

#   }