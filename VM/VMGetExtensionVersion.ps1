# Get latest TypeHandlerVersion
# Get-AzVMImagePublisher -Location eastus 
#   (or whatever location), if you're having trouble finding the publisherName
$allVersions= (Get-AzVMExtensionImage -Location eastus -PublisherName "Microsoft" -Type "ServiceFabricNode").Version
$typeHandlerVer = $allVersions[($allVersions.count) - 1]
$typeHandlerVerMjandMn = $typeHandlerVer.split(".")
$typeHandlerVerMjandMn = $typeHandlerVerMjandMn[0] + "." + $typeHandlerVerMjandMn[1]

write-host $typeHandlerVer