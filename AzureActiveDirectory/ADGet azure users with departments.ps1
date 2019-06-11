#  Connect-AzureAD


#  Connect-MsolService


$Path = "c:\scripts\Users_16_Nov_2018.csv"

Get-MsolUser -MaxResults 10000 | Select-Object Displayname , Department, UsageLocation | Export-CSV -Path $Path -UseCulture -Encoding ascii -NoTypeInformation
| Export-CSV -Path $Path -UseCulture -Encoding ascii -NoTypeInformation


Get-MsolUser -MaxResults 5000 -Department 10034791 |  Select-Object UserPrincipalName , DisplayName, Department -ExpandProperty StrongAuthenticationUserDetails | Export-CSV -Path $Path -UseCulture -Encoding ascii -NoTypeInformation


Get-MsolUser -MaxResults 5000  | sort Department, displayname  | Select-Object SignInName, DisplayName, Department -ExpandProperty StrongAuthenticationUserDetails | FT

Get-MsolUser -MaxResults 5000 -Department 10034791 | sort displayname  | Select-Object SignInName, DisplayName, Department -ExpandProperty StrongAuthenticationUserDetails | ogv

Get-MsolUser -MaxResults 50000| Select UserPrincipalName, WhenCreated, LastPasswordChangeTimestamp, PasswordNeverExpires, AlternateEmailAddresses, Department | ogv

Get-MsolUser  -MaxResults 50000  | Sort SigninName | Select-Object ObjectID, SignInName, AlternateEmailAddresses, DisplayName, Department -ExpandProperty StrongAuthenticationUserDetails | ogv

Get-AzureADUser -Top 50000  |Sort PasswordPolicies, Department, PasswordProfile, UserPrincipalName  |Select UserPrincipalName, Department,PasswordPolicies, PasswordProfile | ogv



$Path = "c:\scripts\Users_4_Jan_2019.csv"
Get-MsolUser -MaxResults 50000| Select UserPrincipalName, WhenCreated, LastPasswordChangeTimestamp, PasswordNeverExpires, Department  | Export-CSV -Path $Path -UseCulture -Encoding ascii -NoTypeInformation