function Get-PaSecurityPolicy {
    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName = "rulebase", Mandatory = $False, Position = 0)]
        [Parameter(ParameterSetName = "prerulebase", Mandatory = $False, Position = 0)]
        [Parameter(ParameterSetName = "postrulebase", Mandatory = $False, Position = 0)]
        [string]$Name,

        [Parameter(ParameterSetName = "prerulebase", Mandatory = $True)]
        [switch]$PreRulebase,

        [Parameter(ParameterSetName = "postrulebase", Mandatory = $True)]
        [switch]$PostRulebase
    )

    BEGIN {
        $VerbosePrefix = "Get-PaSecurityPolicy:"

        # get the right xpath (panorama vs regular)
        switch ($PsCmdlet.ParameterSetName) {
            'postrulebase' {
                $XPathNode = 'post-rulebase/security/rules'
            }
            'prerulebase' {
                $XPathNode = 'pre-rulebase/security/rules'
            }
            'rulebase' {
                $XPathNode = 'rulebase/security/rules'
            }
        }

        $ResponseNode = 'rules'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $null)
    }

    PROCESS {
        if ($null -ne $Global:PaDeviceObject) {
            $Entries = $global:PaDeviceObject.Config.config.devices.entry.vsys.entry.rulebase.security.rules.entry
        } else {
            # Get the config info for the report
            # This is required for the call to run the report
            $Response = Invoke-PaApiConfig -Get -Xpath $XPath
            if ($Response.response.result.$ResponseNode) {
                $Entries = $Response.response.result.$ResponseNode.entry
            } else {
                $Entries = $Response.response.result.entry
            }
        }

        $ReturnObject = @()
        $i = 0
        foreach ($entry in $Entries) {
            $i++
            # Initialize object, add to returned array
            $Object = [PaSecurityPolicy]::new([HelperXml]::parseCandidateConfigXml($entry.name, $false))
            $ReturnObject += $Object


            # General
            $Object.Number = $i
            $Object.RuleType = [HelperXml]::parseCandidateConfigXml($entry.'rule-type', $false)
            $Object.Description = [HelperXml]::parseCandidateConfigXml($entry.description, $false)
            $Object.Tags = [HelperXml]::GetMembersFromXml($entry.tag)

            # Source
            $Object.SourceZone = [HelperXml]::GetMembersFromXml($entry.from)
            $Object.SourceAddress = [HelperXml]::GetMembersFromXml($entry.source)

            # User
            $Object.SourceUser = [HelperXml]::GetMembersFromXml($entry.'source-user')
            $Object.HipProfile = [HelperXml]::GetMembersFromXml($entry.'hip-profiles')

            # Destination
            $Object.DestinationZone = [HelperXml]::GetMembersFromXml($entry.to)
            $Object.DestinationAddress = [HelperXml]::GetMembersFromXml($entry.destination)

            # Application
            $Object.Application = [HelperXml]::GetMembersFromXml($entry.application)

            # Service/Url Category
            $Object.Service = [HelperXml]::GetMembersFromXml($entry.service)
            $Object.UrlCategory = [HelperXml]::GetMembersFromXml($entry.category)

            # Actions
            ## Action Setting
            $Object.Action = [HelperXml]::parseCandidateConfigXml($entry.action, $false)
            $SendIcmpUnreachable = [HelperXml]::parseCandidateConfigXml($entry.'icmp-unreachable', $false)
            $Object.SendIcmpUnreachable = [HelperApi]::TranslatePaToBool($SendIcmpUnreachable, $Object.SendIcmpUnreachable)

            ## Profile Setting
            $Object.ProfileType = [HelperXml]::parseCandidateConfigXml($entry.'profile-setting', $true)
            switch ($Object.ProfileType) {
                'group' {
                    $Object.GroupProfile = [HelperXml]::GetMembersFromXml($entry.'profile-setting'.group)
                }
                'profiles' {
                    $Object.Antivirus = [HelperXml]::GetMembersFromXml($entry.'profile-setting'.profiles.virus)
                    $Object.VulnerabilityProtection = [HelperXml]::GetMembersFromXml($entry.'profile-setting'.profiles.vulnerability)
                    $Object.AntiSpyware = [HelperXml]::GetMembersFromXml($entry.'profile-setting'.profiles.spyware)
                    $Object.UrlFiltering = [HelperXml]::GetMembersFromXml($entry.'profile-setting'.profiles.'url-filtering')
                    $Object.FileBlocking = [HelperXml]::GetMembersFromXml($entry.'profile-setting'.profiles.'file-blocking')
                    $Object.DataFiltering = [HelperXml]::GetMembersFromXml($entry.'profile-setting'.profiles.'data-filtering')
                    $Object.WildFireAnalysis = [HelperXml]::GetMembersFromXml($entry.'profile-setting'.profiles.'wildfire-analysis')
                }
            }

            ## Log Setting
            $LogStart = [HelperXml]::parseCandidateConfigXml($entry.'log-start', $false)
            $Object.LogAtSessionStart = [HelperApi]::TranslatePaToBool($LogStart, $Object.LogAtSessionStart)

            $Object.LogForwarding = [HelperXml]::parseCandidateConfigXml($entry.'log-setting', $false)

            $LogEnd = [HelperXml]::parseCandidateConfigXml($entry.'log-end', $false)
            if ($LogEnd) {
                $Object.LogAtSessionEnd = [HelperApi]::TranslatePaToBool($LogEnd, $Object.LogAtSessionEnd)
            }

            ## Other Settings
            $Object.Schedule = [HelperXml]::parseCandidateConfigXml($entry.schedule, $false)

            $Dsri = [HelperXml]::parseCandidateConfigXml($entry.option.'disable-server-response-inspection', $false)
            $Object.Dsri = [HelperApi]::TranslatePaToBool($Dsri, $Object.Dsri)

            $QosMarkingType = [HelperXml]::parseCandidateConfigXml($entry.qos.marking, $true)

            switch ($QosMarkingType) {
                'follow-c2s-flow' {
                    $Object.QosType = 'FollowC2S'
                }
                'ip-precedence' {
                    $Object.QosType = 'IpPrecedence'
                    $Object.QosMarking = [HelperXml]::parseCandidateConfigXml($entry.qos.marking.'ip-precedence', $false)
                }
                'ip-dscp' {
                    $Object.QosType = 'IpDscp'
                    $Object.QosMarking = [HelperXml]::parseCandidateConfigXml($entry.qos.marking.'ip-dscp', $false)
                }
            }
        }

        if ($Name) {
            $ReturnObject = $ReturnObject | Where-Object { $_.Name -eq $Name }
        }

        $ReturnObject
    }
}