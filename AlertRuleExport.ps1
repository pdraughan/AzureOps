$Names = (Get-AzResourceGroup -OutVariable RG).ResourceGroupName

foreach ($name in $Names)
{
Get-AzAlertRule -ResourceGroupName $name -DetailedOutput
}
