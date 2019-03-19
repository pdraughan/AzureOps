#select a user, and set their password to something of your choosing. Toggle "-ForceChangePasswordNextLogin" if you DON'T want the user to create a new password at next login.
# Need to add the random password line.
$ADUserID = (Get-AzureADUser -Top 10000 | ogv -PassThru).objectid
$TempPass = (Read-Host -Prompt "enter Temporary Password (Capital first letter, then three more letters, followed by four numbers")
# use the following line if you want it to be randomly assigned:
# $TempPass = "([char[]](Get-Random -Input $(48..57 + 65..90 + 97..122) -Count 8)) -join """

$SecurePass = ConvertTo-SecureString -String $TempPass -AsPlainText -Force
Set-AzureADUserPassword -ObjectId $ADUserID -Password $SecurePass -ForceChangePasswordNextLogin $true