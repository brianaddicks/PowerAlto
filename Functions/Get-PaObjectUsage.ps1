function Get-PaObjectUsage {
    <#
	.SYNOPSIS
		Returns Security, Nat, Address and Address Group usge of specific search string.
	.DESCRIPTION
		
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
        [String]$PaConnection,

        [Parameter(Mandatory=$False)]
        [alias('u')]
        [Switch]$Update
    )

    BEGIN {
        Function Process-Query ( [String]$PaConnectionString ) {
            if ((!($Global:SecurityRuleBase)) -or ($Update)) {
                "updating rules"
                $Global:SecurityRuleBase = Get-PaSecurityRule
                $Global:NatRuleBase = Get-PaNatRule
            }
            $SecurityRuleBase = $Global:SecurityRuleBase
            $NatRuleBase = $Global:NatRuleBase


            #if (!($SecurityRuleBase)) { $SecurityRuleBase = Get-PaSecurityRule }
            #if (!($NatRuleBase)) { $NatRuleBase = Get-PaNatRule }
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

        $ReturnObject = @{}
        $ReturnObject.Addresses = $Objects.Addresses
        $ReturnObject.Groups = $Objects.Groups
        $ReturnObject.SecurityRules = $SecurityRuleUse
        $ReturnObject.NatRules = $NatRuleUse
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