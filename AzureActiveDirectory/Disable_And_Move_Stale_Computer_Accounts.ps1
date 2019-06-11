# Set the days to over 120
$d = [DateTime]::Today.AddDays(-120)

# Get list of computer that have the PasswordLastSet to numner of day and excludes the Disabled_Computers OU
$Computers =  Get-ADComputer -Filter 'PasswordLastSet -le $d' -Properties Description | where { ($_.DistinguishedName -notlike "*OU=Disabled_Computers,*")}

# Foreach loop
ForEach ($Computer in $Computers){

# Writes to a log file with Computer name and date of move
Add-Content c:\scripts\computers.log -Value "$Computer, disabling and moved to Disabled_Computers OU on $(Get-Date)"

# Set the computer account to disabled
Set-ADComputer $Computer -Description "Computer Disabled on $(Get-Date) by Disabled scripts" -Enabled $false


# Moves the computer to the disabled OU
Move-ADObject $computer -targetpath “OU=Disabled_Computers,DC=xxxxxxxx,DC=com”

}

