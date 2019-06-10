$ADUserID = (Get-AzureADUser -Top 10000 | ogv -PassThru).objectid
$Password = (Read-Host -Prompt "enter Temporary Password (Capital first letter, then three more letters, followed by four numbers")

$SecurePassword = ConvertTo-SecureString '$Password' –asplaintext –force
Set-AzureADUserPassword -ObjectId $ADUserID  -Password $SecurePassword -ForceChangePasswordNextLogin $false