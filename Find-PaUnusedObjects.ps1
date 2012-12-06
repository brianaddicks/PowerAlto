function Find-PaUnusedObjects {
    <#
	.SYNOPSIS
		Returns Security Ruleset from Palo Alto firewall.
	.DESCRIPTION
		Returns Security Ruleset from Palo Alto firewall.
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey.
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection
    )

    BEGIN {
        $ResultObject = @{}
        $ResultProperties = @("Name","Groups","Security","Nat")
        foreach ($Value in $ResultProperties) {
            $ResultObject.Add($Value,$null)
        }

        Function Process-Query ( [String]$PaConnectionString ) {
            $ResultTable = @()
            $Addresses = (Send-PaApiQuery -Config get -xpath "/config/devices/entry/vsys/entry/address" -pc $PaConnectionString).response.result.address.entry
            $i = 0
            foreach ($Address in $Addresses) {
                $Usage = Get-PaObjectUsage $Address.name
                $CurrentResult = New-Object PsObject -Property $ResultObject
                $CurrentResult.Name     = $Address.name
                $CurrentResult.Groups   = ($Usage.Groups | measure).count
                $CurrentResult.Security = ($Usage.Security | measure).count
                $CurrentResult.Nat      = ($Usage.NatRules | measure).count
                $ResultTable += $CurrentResult
                $i++
                $Progress = [math]::truncate(($i / $Addresses.count) * 100)
                Write-Progress -Activity "Scanning Address Usage" -Status "$Progress% complete $i/$($Addresses.count)"-PercentComplete $Progress
            }
        return $ResultTable
        }
    }
    
    PROCESS {
        if ($PaConnection) {
            Process-Query $PaConnection
        } else {
            if (Test-PaConnection) {
                foreach ($Connection in $Global:PaConnectionArray) {
                    Process-Query $Connection.ConnectionString
                }
            } else {
                Throw "No Connections"
            }
        }
    }
}