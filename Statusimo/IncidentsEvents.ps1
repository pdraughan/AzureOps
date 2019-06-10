Import-Module Statusimo

$newStatusimoIncidentSplat = @{
    Date       = (Get-Date)
    Overview   = "overview"
    Title      = 'Things are fine'
    Status     = 'Operational'
    Service    = 'Service Name'
    FolderPath = "$PSScriptRoot\Incidents"
}
New-StatusimoEvent @newStatusimoIncidentSplat

New-StatusimoEvent -FolderPath $PSScriptRoot\Incidents -Date (Get-Date) -Service 'Status page' -Status 'Operational' -Title 'Status Title' -Overview "Everything is Awesome."