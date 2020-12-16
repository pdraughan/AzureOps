## This script will create tags on Azure resources.

# If the Vaule is already present then it will not be added twice.

# This function is used to join the hash tables for the tags
function AddToTable($table) {

    $table.GetEnumerator() |
    % 
    {
        if (!$newTable.ContainsKey($_.Key)) { $newTable.Add($_.Key, $_.Value) }
        else { $newTable[$_.Key] += ",$($_.Value)" }

        $newTable[$_.Key] = @($newTable[$_.Key].Split(",") | Get-Unique | Sort-Object) -Join ","
    }
}

# Get the user to input the Key Name and the value ID they want to add to the TAG.

$KeyName = Read-Host "Enter the name tag name that you want to add."
$Client = Read-Host "Enter in the tag value that you want to be assiged."

# Get the user to select the Azure resouces the new tag will be applied.

$resources = (Get-AzResource | Sort ResourceGroupName, Name | Select ResourceGroupName, Name, ResourceType, ResourceId | OGV -Title "Select the resouces to be tag." -PassThru).resourceid

# Script will run thru all resouces.

foreach ($resource in $Resources) {

    # Retrieve existing resource tags, if any
    $tags = (Get-AzResource -ResourceID $resource).Tags
    # This uses the above function to merge the current tags with the new tag.
    $NewValue = @{$KeyName = "$Client" }

    $newTable = @{}
    AddToTable($NewValue)
    AddToTable($tags)

    Set-AzResource -ResourceId $resource -Tag $newTable -Force
    # You can wrtie the output to a file is desired.
    # Write-Output $resource,$newTable >> c:\scripts\Tags.csv

}