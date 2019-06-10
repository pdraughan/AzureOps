
## Connect-AzureAD

$Excel = New-Object -ComObject Excel.Application

function OpenExcelBook ($FileName) {
    return $Excel.workbooks.open($FileName)
}

function CloseExcelBook ($Workbook) {
    #$Workbook.save()
    $Workbook.close()
}

function ReadCellData ($Workbook, $Cell) {
    $Worksheet = $Workbook.Activesheet
    return $Worksheet.Range($Cell).text
}

# Update filepath!

function CreateUsers() {
    $Workbook = OpenExcelBook –Filename 'C:\scripts\Import_14_Jan_2019.xlsx'

    $row = 1
   
    do {
        $FirstName = ReadCellData -Workbook $Workbook -Cell "A$row"
        $LastName = ReadCellData -Workbook $Workbook -Cell "B$row"
        $userName = "${FirstName}.${LastName}@avenel.com"
        $Email = ReadCellData -Workbook $Workbook -Cell "C$row"
        $Department = ReadCellData  -Workbook $Workbook -Cell "D$row"
        $UserLocation = ReadCellData -Workbook $Workbook -Cell "E$row" 
        $JobTitle = ReadCellData  -Workbook $Workbook -Cell "F$row"
        $TempPass = ReadCellData -Workbook $Workbook -Cell "G$row"
        ##$TempPass = ([char[]](Get-Random -Input $(48..57 + 65..90 + 97..122) -Count 12)) -join "" 

        # Create the Temporary Password for the Users
        $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $PasswordProfile.Password = $TempPass

        # Create AD User
        
        New-AzureADUser -DisplayName "${FirstName} ${LastName}" `
                        -UserPrincipalName $userName `
                        -UserType Member -Department $Department `
                        -OtherMails $Email `
                        -PasswordProfile $PasswordProfile `
                        -Surname $LastName -GivenName $FirstName `
                        -JobTitle $JobTitle `
                        -MailNickName "${FirstName}.${LastName}" `
                        -UsageLocation "$UserLocation" `
                        -AccountEnabled $true `

        $row++
     } while ($row -lt 1)

    CloseExcelBook –workbook $Workbook
}

CreateUsers


