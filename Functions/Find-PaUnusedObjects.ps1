function Find-PaUnusedObjects {
    <#
	.SYNOPSIS
		Find unused Address Objects and Address Groups.
	.DESCRIPTION
		
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection,

        [Parameter(Mandatory=$False)]
        [alias('u')]
        [Switch]$Update
    )

    BEGIN {
        $ResultObject = @{}
        $ResultProperties = @("Name","Groups","Security","Nat")
        foreach ($Value in $ResultProperties) {
            $ResultObject.Add($Value,$null)
        }

        Function Process-Query ( [String]$PaConnectionString ) {
            $ResultTable = @()
            if ((!($Global:Addresses)) -or ($Update)) {
                "updating addresses and rulebase"
                $Global:Addresses = (Send-PaApiQuery -Config get -xpath "/config/devices/entry/vsys/entry/address" -pc $PaConnectionString).response.result.address.entry
                $Global:AddressGroups = (Send-PaApiQuery -Config get -xpath "/config/devices/entry/vsys/entry/address-group"-pc $PaConnectionString).response.result."address-group".entry
                $Global:SecurityRuleBase = Get-PaSecurityRule
                $Global:NatRuleBase = Get-PaNatRule
            }
            $Addresses = $Global:Addresses
            $AddressGroups = $Global:AddressGroups
            $All = $Addresses + $AddressGroups
            $i = 0
            foreach ($item in $All) {
                $Usage = Get-PaObjectUsage $item.name
                $CurrentResult = New-Object PsObject -Property $ResultObject
                $CurrentResult.Name     = $item.name
                $CurrentResult.Groups   = ($Usage.Groups | measure).count
                $CurrentResult.Security = ($Usage.SecurityRules | measure).count
                $CurrentResult.Nat      = ($Usage.NatRules | measure).count
                $ResultTable += $CurrentResult
                $i++
                $Progress = [math]::truncate(($i / $all.count) * 100)
                Write-Progress -Activity "Scanning Address Usage" -Status "$Progress% complete"-PercentComplete $Progress
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