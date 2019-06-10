## This scipt is used to find all services that are using a specific service account. 
## You will need the Active Directory Module installed to complete this script


$Username1 = Read-host "What account name do you want to change?"
$Domain = "domain"

$UserName = "$Domain\$UserName1"  
$Password = Read-Host "What is the new password of the account?" 
# Use the $Cred line if you are required to  run the script as a differnt users than that is logged in.
# $Cred = Get-Credential #Prompt you for user name and password 

# This is the search crieteria. You must be able to connect to each VM in order for the script to complete correctly

# This will search for all computer with warren in the name
# $Computer1 = Get-ADComputer -filter 'Name -like "*computer*"' 

# This will list all computers in avenel
$Computer1 = Get-ADComputer -Filter *

# This will list all computer in a specific OU. Currently this list all user in the HST_DEV OU that is under the Hosting OU.
# $Computer1 = Get-ADComputer -LDAPFilter "(Name=*)" -SearchBase "OU=HST_DEV,OU=OUFolder,DC=DomainName,DC=com"


foreach($Comp in $Computer1){
# $ErrorActionPreference = "Stop"

 if (Test-Connection $comp.Name -Count 1 -ea 0 )
 {

#$ErrorActionPreference = "SilentlyContinue"
# This identifies all the server that have a service that is running using a specifc service account
$Computer2 = gwmi "win32_service" -ComputerName $Comp.Name | ?{$_.StartName -match "$Username1" }| Select SystemName , Name

   foreach ($Comp2 in $Computer2){
# This turns off error notifications only inside of the script. 
$ErrorActionPreference = "SilentlyContinue"

# This goes thru all service account that were identified and stops the service, Reset the password and attempts to start the service.
   $ServerN = $Comp2.SystemName
   $Service = $Comp2.Name

# Comment this line out if you are required to  run the script as a differnt users than that is logged in.
      $svcD=gwmi win32_service -computername $ServerN -filter "name='$service'" 
  
# Use this line if you are required to  run the script as a differnt users than that is logged in.  
    # $svcD=gwmi win32_service -computername $ServerN -filter "name='$service'" -Credential $cred 
      $StopStatus = $svcD.StopService() 
If ($StopStatus.ReturnValue -eq "0") # validating status - http://msdn.microsoft.com/en-us/library/aa393673(v=vs.85).aspx 
    {write-host "$ServerN -> $Service Service Stopped Successfully"} 
$ChangeStatus = $svcD.change($null,$null,$null,$null,$null,$null,$UserName,$Password,$null,$null,$null) 
If ($ChangeStatus.ReturnValue -eq "0")  
    {write-host "$ServerN -> $Service Sucessfully Changed User Name"} 
$StartStatus = $svcD.StartService() 
If ($StartStatus.ReturnValue -eq "0")  
    {write-host "$ServerN -> $Service Service Started Successfully"} 


}
Else
{}
   }

}