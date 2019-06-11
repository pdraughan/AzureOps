$RefObj = (Get-AzureADGroup | ogv -PassThru).ObjectId
Get-AzureADAdministrativeUnit -OutVariable AUTest
Add-AzureADAdministrativeUnitMember -ObjectId $AUTest.ObjectId -RefObjectId $RefObj