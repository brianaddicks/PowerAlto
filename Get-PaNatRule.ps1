function Get-PaNatRule {
    <#
	.SYNOPSIS
		Returns NAT Ruleset from Palo Alto firewall.
	.DESCRIPTION
		
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
        $xpath = "/config/devices/entry/vsys/entry/rulebase/nat/rules"
        function Text-Query ( [String]$PaProp ) {
            if ($entry."$PaProp"."#text") { return $entry."$PaProp"."#text" } `
                else { return  $entry."$PaProp" }
        }
        function Member-Query ( [String]$PaProp ) {
            if ($entry."$PaProp".member."#text") { return $entry."$PaProp".member."#text" } `
                else { return  $entry."$PaProp".member }
        }
        Function Process-Query ( [String]$PaConnectionString ) {
            $NatRule = @{}
            $ExportString = @("Name","Description","Tag","SourceZone","DestinationZone","DestinationInterface","Service","SourceAddress","DestinationAddress","SourceTransType","SourceTransAddressType","SourceTransInterface","SourceTransAddress","BiDirectional","DestTransEnabled","DestTransAddress","DestTransPort")
            foreach ($Value in $ExportString) {
                $NatRule.Add($Value,$null)
            }
            $NatRules = @()
            $NatRulebase = (Send-PaApiQuery -Config get -XPath $xpath -pc $PaConnectionString).response.result.rules.entry
            
            #Covert results into PSobject
            foreach ($entry in $NatRulebase) {
                $CurrentRule = New-Object PSObject -Property $NatRule

                $CurrentRule.Name                   = $entry.Name
                $CurrentRule.Description            = $entry.Description
                $CurrentRule.Tag                    = Member-Query "tag"
                $CurrentRule.SourceZone             = Member-Query "from"
                $CurrentRule.DestinationZone        = Member-Query "to"
                $CurrentRule.DestinationInterface   = Text-Query "to-interface"
                $CurrentRule.Service                = Text-Query "service"
                $CurrentRule.SourceAddress          = Member-Query "source"
                $CurrentRule.DestinationAddress     = Member-Query "destination"
                if ($entry."source-translation"."dynamic-ip-and-port") {
                    $CurrentRule.SourceTransType    = "DynamicIpAndPort"
                    if ($entry."source-translation"."dynamic-ip-and-port"."interface-address".interface."#text") {
                        $CurrentRule.SourceTransAddressType = "InterfaceAddress"
                        $CurrentRule.SourceTransInterface   = $entry."source-translation"."dynamic-ip-and-port"."interface-address".interface."#text"
                        $CurrentRule.SourceTransAddress      = $entry."source-translation"."dynamic-ip-and-port"."interface-address".ip."#text"
                    } elseif ($entry."source-translation"."dynamic-ip-and-port"."interface-address".interface) {
                        $CurrentRule.SourceTransAddressType = "InterfaceAddress"
                        $CurrentRule.SourceTransInterface   = $entry."source-translation"."dynamic-ip-and-port"."interface-address".interface
                    } elseif ($entry."source-translation"."dynamic-ip-and-port"."translated-address") {
                        $CurrentRule.SourceTransAddressType = "TranslatedAddress"
                        $CurrentRule.SourceTransInterface   = $entry."source-translation"."dynamic-ip-and-port"."translated-address".member."#text"
                    }
                } elseif ($entry."source-translation"."static-ip") {
                    $CurrentRule.SourceTransType    = "StaticIp"
                    $CurrentRule.SourceTransAddress = $entry."source-translation"."static-ip"."translated-address"."#text"
                    $CurrentRule.BiDirectional      = $entry."source-translation"."static-ip"."bi-directional"."#text"
                } elseif ($entry."source-translation"."dynamic-ip") {
                    $CurrentRule.SourceTransType    = "DynamicIp"
                    $CurrentRule.SourceTransAddress = $entry."source-translation"."dynamic-ip"."translated-address".member."#text"
                }
                if ($entry."destination-translation") {
                    $CurrentRule.DestTransEnabled = "yes"
                    $CurrentRule.DestTransAddress = $entry."destination-translation"."translated-address"."#text"
                    $CurrentRule.DestTransPort    = $entry."destination-translation"."translated-port"."#text"
                }
                $NatRules += $CurrentRule
            }
            return $NatRules | select $ExportString
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

