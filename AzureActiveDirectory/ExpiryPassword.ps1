foreach ($user in Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed", "EmailAddress" | 
Where-Object {$_.EmailAddress -ne $null}| Select-Object -Property "Displayname","EmailAddress",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | 
Where-Object {(new-timespan -end $_.ExpiryDate).days -lt 7 -and (new-timespan -end $_.ExpiryDate).days -gt 0}) {Out-GridView}

<#
Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" |
Select-Object -Property "UserPrincipalName",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | Export-Csv C:\Users\philip.draughan.AVENEL\Desktop\azuread.csv
#>