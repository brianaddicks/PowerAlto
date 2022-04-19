function Get-PaNatPolicy {
    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName = "rulebase", Mandatory = $False, Position = 0)]
        [Parameter(ParameterSetName = "prerulebase", Mandatory = $False, Position = 0)]
        [Parameter(ParameterSetName = "postrulebase", Mandatory = $False, Position = 0)]
        [string]$Name,

        [Parameter(ParameterSetName = "prerulebase", Mandatory = $True)]
        [switch]$PreRulebase,

        [Parameter(ParameterSetName = "postrulebase", Mandatory = $True)]
        [switch]$PostRulebase,

        [Parameter(ParameterSetName = "rulebase", Mandatory = $false)]
        [switch]$PushedSharedPolicy
    )

    BEGIN {
        $VerbosePrefix = "Get-PaNatPolicy:"

        # get the right xpath (panorama vs regular)
        switch ($PsCmdlet.ParameterSetName) {
            'postrulebase' {
                $XPathNode = 'post-rulebase/nat/rules'
            }
            'prerulebase' {
                $XPathNode = 'pre-rulebase/nat/rules'
            }
            'rulebase' {
                $XPathNode = 'rulebase/nat/rules'
            }
        }

        $ResponseNode = 'rules'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $Name)
    }

    PROCESS {
        if ($null -ne $Global:PaDeviceObject.Config) {
            $Entries = $global:PaDeviceObject.Config.config.devices.entry.vsys.entry.rulebase.nat.rules.entry
        } else {

            if ($PushedSharedPolicy) {
                $PushedSharedPolicyResponse = Invoke-PaApiOperation '<show><config><pushed-shared-policy></pushed-shared-policy></config></show>'
                $PreRulebaseResponse = $PushedSharedPolicyResponse.response.result.policy.panorama.'pre-rulebase'.nat.rules.entry
                $PostRulebaseResponse = $PushedSharedPolicyResponse.response.result.policy.panorama.'post-rulebase'.nat.rules.entry
            }

            $Response = Invoke-PaApiConfig -Get -Xpath $XPath

            if ($Response.response.result.$ResponseNode) {
                $Entries = $Response.response.result.$ResponseNode.entry
            } else {
                $Entries = $Response.response.result.entry
            }

            $AllEntries = @()

            foreach($rulebase in @($PreRulebaseResponse,$Entries,$PostRulebaseResponse)) {
                foreach ($entry in $rulebase) {
                    $AllEntries += $entry
                }
            }
            Write-Verbose "$VerbosePrefix Found $($AllEntries.Count) NAT entries."
        }

        $ReturnObject = @()
        #foreach ($entry in $Entries) {
        foreach ($entry in $AllEntries) {
            # Initialize Report object, add to returned array
            $Object = [PaNatPolicy]::new([HelperXml]::parseCandidateConfigXml($entry.name, $false))
            $ReturnObject += $Object

            # Add simple properties

            # General
            $Object.Description = [HelperXml]::parseCandidateConfigXml($entry.description, $false)
            $Object.NatType = [HelperXml]::parseCandidateConfigXml($entry.'nat-type', $false)
            $Object.Tags = [HelperXml]::parseCandidateConfigXml($entry.tag.member, $false)

            # Original Packet
            $Object.SourceZone = [HelperXml]::parseCandidateConfigXml($entry.from.member, $false)
            $Object.DestinationZone = [HelperXml]::parseCandidateConfigXml($entry.to.member, $false)
            $Object.DestinationInterface = [HelperXml]::parseCandidateConfigXml($entry.'to-interface', $false)
            $Object.Service = [HelperXml]::parseCandidateConfigXml($entry.service, $false)
            $Object.SourceAddress = [HelperXml]::parseCandidateConfigXml($entry.source.member, $false)
            $Object.DestinationAddress = [HelperXml]::parseCandidateConfigXml($entry.destination.member, $false)

            # Translated Packet
            ## Static IP
            $SourceTranslationType = [HelperXml]::parseCandidateConfigXml($entry.'source-translation', $true)
            $Object.SourceTranslationType = $SourceTranslationType
            if ($entry.'source-translation'.$SourceTranslationType.'translated-address'.member) {
                $Object.SourceTranslatedAddress = [HelperXml]::parseCandidateConfigXml($entry.'source-translation'.$SourceTranslationType.'translated-address'.member, $false)
            } else {
                $Object.SourceTranslatedAddress = [HelperXml]::parseCandidateConfigXml($entry.'source-translation'.$SourceTranslationType.'translated-address', $false)
            }

            $Bidirectional = [HelperXml]::parseCandidateConfigXml($entry.'source-translation'.$SourceTranslationType.'bi-directional', $false)
            if ($Bidirectional -eq 'yes') {
                $Object.BiDirectional = $true
            }

            $Disabled = [HelperXml]::parseCandidateConfigXml($entry.disabled, $false)
            if ($Disabled -eq 'yes') {
                $Object.Disabled = $true
            }

            if ($entry.'destination-translation') {
                $Object.TranslatedDestinationAddress = [HelperXml]::parseCandidateConfigXml($entry.'destination-translation'.'translated-address', $false)
            }

            #$Object.TranslatedDestinationAddress
            #$Object.TranslatedDestinationPort
        }

        $ReturnObject
    }
}