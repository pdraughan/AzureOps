$ADUserID = (Get-AzureADUser -Top 10000 | ogv -PassThru).objectid
Set-AzureADUser -ObjectId $ADUserID -PasswordPolicies DisablePasswordExpiration