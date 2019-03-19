
<#
Names and information should be in an Excel worksheet. Columns expected (no header row) are in the following order:
        FirstName  LastName  Email  TempPass  Department  JobTitle
To use, have a properly formatted Excel sheet at the location specific in "-Filename" below
Go to the bottom of the script, and alter "while ($row -lt 4)" so that the number accurately represents the number of rows LESS THAN the number of users being created. For example, "-lt 4" means that only 3 rows' worth of Users (3 users) will be created.
#>

Connect-AzureAD

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
    $Workbook = OpenExcelBook –Filename 'C:\Users\Generic\Desktop\Template.xlsx'

    $row = 1
    
    do {
        $FirstName = ReadCellData -Workbook $Workbook -Cell "A$row"
        $LastName = ReadCellData -Workbook $Workbook -Cell "B$row"
        $userName = "${FirstName}.${LastName}@avenel.com"
        $Email = ReadCellData -Workbook $Workbook -Cell "C$row"
        $TempPass = ReadCellData -Workbook $Workbook -Cell "D$row"
        $Department = ReadCellData  -Workbook $Workbook -Cell "E$row"
        $JobTitle = ReadCellData  -Workbook $Workbook -Cell "F$row"

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
                        -UsageLocation "US" `
                        -AccountEnabled $true `

        $row++
     } while ($row -lt 4)

    CloseExcelBook –workbook $Workbook
}

CreateUsers