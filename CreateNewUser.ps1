# Once proper administrative credentials are supplied, create a user in AzureAD based on supplied values.
# Connect to the Azure Active Directory
# $AzureADCred = Get-Credential -Message "Please sign in with Admin Credentials"
# ^ Does not work if/when MFA is enabled.
Connect-AzureAD #-Credential $AzureADCred 

# Replace the following variables' values, but don't touch $username or $PasswordProfile. Heed the $Department as it can trigger a Dynamic group membership
$FirstName = "First"
$LastName = "Last"
$Email = "First.Last@Email.com"
$JobTitle = "Support Engineer"
$Department = "Support"

#Don't touch
$userName = "${FirstName}.${LastName}@domain.com"
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$TempPass = "([char[]](Get-Random -Input $(48..57 + 65..90 + 97..122) -Count 8)) -join """

# Update the password. I advise you stick with capital first of four letters, then four numbers (it is easy to communicate and avoids confusion).
$PasswordProfile.Password = $TempPass

# cmdlet to Create AD User
New-AzureADUser -DisplayName "${FirstName} ${LastName}" `
                -UserPrincipalName $userName `
                -UserType Member -Department $Department `
                -OtherMails $Email `
                -MailNickName "${FirstName}.${LastName}" `
                -PasswordProfile $PasswordProfile `
                -Surname $LastName -GivenName $FirstName `
                -JobTitle $JobTitle `
                -UsageLocation "US" `
                -AccountEnabled $true ` | Select DisplayName, ObjectID, UserPrincipalName, $Email, $PasswordProfile.Password
                # Copy/paste output values as needed (ie send email with the Password to the newly created user).