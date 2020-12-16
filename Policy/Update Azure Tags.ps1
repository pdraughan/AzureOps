
#Get the user to input the client ID they want to add to the TAG.
$Client = Read-Host "What is your client ID"


#Get a reference to an Azure resource

$resources = (Get-AzResource | Sort ResourceGroupName, Name | Select ResourceGroupName, Name, ResourceType, ResourceId | OGV -Title "Select the resouces to be tag." -PassThru).resourceid

foreach ($resource in $Resources) {

  #Retrieve existing resource tags, if any
  $tags = (Get-AzResource -ResourceID $resource).Tags

  ##If the resouces does not have the client key
  if ($tags.ContainsKey("client") -match "False") {


    #Add new tags to exiting tags
    $tags += @{Client = "$Client" }


    Set-AzResource -ResourceId $resource -Tag $tags -Force
    Write-Output $resource, $tags, "Step 1" >> c:\scripts\Tags.csv
  }

  ##If the resouces does not have the Client key. The Key value is case sensistive. 
  elseif ($tags.ContainsKey("Client") -match "False") {

    $tags += @{Client = "$Client" }

    Set-AzResource -ResourceId $resource -Tag $tags -Force
    Write-Output $resource, $tags, "Step 2" >> c:\scripts\Tags.csv
  }


  ##If the resources has the client key and does not contain the vaule for the ClientID
  elseif ($tags.ContainsValue("$Client") -match "False") {


    $NewValue = @{Client = "$Client" }
    $newTable = @{}


    function AddToTable($table) {
      $table.GetEnumerator() | 
      % {
        if (!$newTable.ContainsKey($_.Key)) { $newTable.Add($_.Key, $_.Value) }
        else { $newTable[$_.Key] += ",$($_.Value)" }
        $newTable[$_.Key] = @($newTable[$_.Key].Split(",") | Get-Unique | Sort-Object) -Join "," 
      }
    }

    AddToTable($NewValue)
    AddToTable($tags)

    Set-AzResource -ResourceId $resource -Tag $tags -Force
    Write-Output $resource, $tags, "step 3" >> c:\scripts\Tags.csv

  }

  elseif ($tags.ContainsValue("$Client") -match "True") {
    Write-Output $resource, $tags, "No Changes to tags" >> c:\scripts\Tags.csv
  }

  #Write new tags to an Azure resource
  #Set-AzResource -ResourceId $resource -Tag $tags -Force

  #Delete all tags and replace with just the Cleint tag
  #Set-AzResource -Tag {Client="$Client"} -ResourceId $resource -Force

  #Remove all tags
  #Set-AzResource -Tag @{} -ResourceId $resource -Force

}
