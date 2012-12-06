function Get-PaObjectUsage {
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
        [Parameter(Mandatory=$True,Position=0)]
        [String]$SearchString,

        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection
    )

    BEGIN {
        $ReturnObject = @{}
        $ReturnProperties = @("Addresses","Groups","SecurityRules","NatRules")
        foreach ($Value in $ReturnProperties) {
            $ReturnObject.Add($Value,$null)
        }
        Function Process-Query ( [String]$PaConnectionString ) {
            $SecurityRuleBase = Get-PaSecurityRule
            $NatRuleBase = Get-PaNatRule
            $Objects = Find-PaAddressObject $SearchString

            $SecurityRuleUse = @()
            $NatRuleUse      = @()

            foreach ($Address in $Objects.Addresses) {
                $SecurityRuleUse += $SecurityRulebase | where { ($_.SourceAddress -contains $Address.Name) -or $_.DestinationAddress -contains $Address.Name }
                $NatRuleUse += $NatRuleBase | where { ($_.SourceAddress -contains $Address.name) -or ($_.DestinationAddress -contains $Address.name) -or ($_.SourceTransAddress -contains $Address.name) -or ($_.DestTransAddress -contains $Address.name) }
            }
            foreach ($Group in $Objects.Groups) {
                $SecurityRuleUse += $SecurityRulebase | where { ($_.SourceAddress -contains $Group.name) -or ($_.DestinationAddress -contains $Group.name) }
                $NatRuleUse += $NatRuleBase | where { ($_.SourceAddress -contains $Group.name) -or ($_.DestinationAddress -contains $Group.name) -or ($_.SourceTransAddress -contains $Group.name) -or ($_.DestTransAddress -contains $Group.name) }
            }

            ""
            if ($Objects) {
                if ($Objects.Addresses) {
                    #Write-Host "$SearchString is a member of the following $($Objects.Addresses.Count) Address(es)"
                    #$Objects.Addresses | ft Name,Value -AutoSize
                    $ReturnObject.Addresses = $Objects.Addresses
                }
                if ($Objects.Groups) {
                    #Write-Host "$SearchString is a member of the following $($Objects.Groups.count) Group(s)"
                    #$Objects.Groups | ft Name,Member -AutoSize
                    $ReturnObject.Groups = $Objects.Groups
                }
            }

            if ($SecurityRuleUse) {
                #Write-Host "$SearchString is used in the following $($SecurityRuleUse.count) Security Rules"
                #$SecurityRuleuse | ft Name,SourceAddress,DestinationAddress -AutoSize
                $ReturnObject.SecurityRules = $SecurityRuleUse
            }

            if ($NatRuleUse) {
                #Write-Host "$SearchString is used in the following $($NatRuleUse.count) Nat Rules"
                #$NatRuleuse | ft Name,SourceAddress,DestinationAddress -AutoSize
                $ReturnObject.NatRules = $NatRuleUse
            }
        return $ReturnObject
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