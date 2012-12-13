function Get-PaSecurityRule {
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
        [String]$PaConnection,

        [Parameter(Mandatory=$False)]
        [alias('c')]
        [Switch]$Candidate,

        [Parameter(Mandatory=$False)]
        [alias('u')]
        [Switch]$Update
    )

    BEGIN {
        $xpath = "/config/devices/entry/vsys/entry/rulebase/security/rules"
        if ($Candidate) { $type = "get" } `
                   else { $type = "show" }

        Function Process-Query ( [String]$PaConnectionString ) {
            $SecurityRule = @{}
            $ExportString = @("Name","Description","Tag","SourceZone","SourceAddress","SourceNegate","SourceUser","HipProfile","DestinationZone","DestinationAddress","DestinationNegate","Application","Service","UrlCategory","Action","ProfileType","ProfileGroup","ProfileVirus","ProfileVuln","ProfileSpy","ProfileUrl","ProfileFile","ProfileData","LogStart","LogEnd","LogForward","DisableSRI","Schedule","QosType","QosMarking","Disabled")
            foreach ($Value in $ExportString) {
                $SecurityRule.Add($Value,$null)
            }
            $SecurityRules = @()
            if ((!($Global:SecurityRuleBase)) -or ($Update)) {
                $Global:SecurityRuleBase = (Send-PaApiQuery -Config $type -XPath $xpath -pc $PaConnectionString).response.result.rules.entry
            }
            $SecurityRulebase = $Global:SecurityRuleBase
            
            #Covert results into PSobject
            foreach ($entry in $SecurityRulebase) {
                $CurrentRule = New-Object PSObject -Property $SecurityRule
                    $CurrentRule.Name               = $entry.name
                    $CurrentRule.Description        = $entry.description
                    $CurrentRule.Tag                = $entry.tag.member
                    $CurrentRule.SourceZone         = $entry.from.member
                    $CurrentRule.SourceAddress      = $entry.source.member
                    $CurrentRule.SourceNegate       = $entry."negate-source"
                    $CurrentRule.SourceUser         = $entry."source-user".member
                    $CurrentRule.HipProfile         = $entry."hip-profiles".member
                    $CurrentRule.DestinationZone    = $entry.to.member
                    $CurrentRule.DestinationAddress = $entry.destination.member
                    $CurrentRule.DestinationNegate  = $entry."negate-destination"
                    $CurrentRule.Application        = $entry.application.member
                    $CurrentRule.Service            = $entry.service.member
                    $CurrentRule.UrlCategory        = $entry.category.member
                    $CurrentRule.Action             = $entry.action
                    if ($entry."profile-setting".group) {
                        $CurrentRule.ProfileGroup   = $entry."profile-setting".group.member
                        $CurrentRule.ProfileType    = "group"
                    } elseif ($entry."profile-setting".profiles) {
                        $CurrentRule.ProfileType    = "profiles"
                        $CurrentRule.ProfileVirus   = $entry."profile-setting".profiles.virus.member
                        $CurrentRule.ProfileVuln    = $entry."profile-setting".profiles.vulnerability.member
                        $CurrentRule.ProfileSpy     = $entry."profile-setting".profiles.spyware.member
                        $CurrentRule.ProfileUrl     = $entry."profile-setting".profiles."url-filtering".member
                        $CurrentRule.ProfileFile    = $entry."profile-setting".profiles."file-blocking".member
                        $CurrentRule.ProfileData    = $entry."profile-setting".profiles."data-filtering".member
                    }
                    $CurrentRule.LogStart           = $entry."log-start"
                    $CurrentRule.LogEnd             = $entry."log-end"
                    $CurrentRule.LogForward         = $entry."log-setting"
                    $CurrentRule.Schedule           = $entry.schedule
                    if ($entry.qos.marking."ip-dscp") {
                        $CurrentRule.QosType        = "ip-dscp"
                        $CurrentRule.QosMarking     = $entry.qos.marking."ip-dscp"
                    } elseif ($entry.qos.marking."ip-precedence") {
                        $CurrentRule.QosType        = "ip-precedence"
                        $CurrentRule.QosMarking     = $entry.qos.marking."ip-precedence"
                    }
                    $CurrentRule.DisableSRI         = $entry.option."disable-server-response-inspection"
                    $CurrentRule.Disabled           = $entry.disabled
                $SecurityRules += $CurrentRule
            }
            #$SecurityRulebase
            return $SecurityRules | select $ExportString
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

