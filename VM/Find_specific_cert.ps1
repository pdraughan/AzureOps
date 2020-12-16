# THis script will only run for a computer that it has access. Run this from the RDLicensing server to reach all subnets.

# Finds all enabled computer accounts in AD
$comps = Get-ADComputer -Filter {(enabled -eq "true")}
# Enter the Certificate Serial number and not the thumbprint
$serial = '1d724cef7228f3c2'


# searches all active servers and list all that have the certificate installed. 
foreach ($comp in $comps)
{
$ErrorActionPreference = "SilentlyContinue"
    if (invoke-command -scriptblock { Get-ChildItem Cert:\LocalMachine -rec | Where-Object { $_.SerialNumber -eq $serial } } -ComputerName $comp.name)
    { write-output "Exists on $comp.name" }
}