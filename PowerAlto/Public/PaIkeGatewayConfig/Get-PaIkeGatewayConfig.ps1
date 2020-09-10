function Get-PaIkeGatewayConfig {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Get-PaIkeGatewayConfig:"
        $XPathNode = 'network/ike/gateway'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $Name)
    }

    PROCESS {
        $Response = Invoke-PaApiConfig -Get -Xpath $XPath
        if ($Response.response.result.$XPathNode) {
            $Entries = $Response.response.result.$XPathNode.entry
        } else {
            $Entries = $Response.response.result.entry
        }

        $ReturnObject = @()
        foreach ($entry in $Entries) {
            # Initialize Report object, add to returned array
            $Object = New-PaIkeGatewayConfig -Name $Name
            $ReturnObject += $Object

            [string]$Interface
            [string]$LocalIPAddress

            [string]$PeerIpAddress

            if ($entry.protocol.ikev2.'ike-crypto-profile') {
                $Object.IkeV2Enabled = $true
                $Object.IkeCryptoProfile = $entry.protocol.ikev2.'ike-crypto-profile'
            }

            if ($entry.protocol.ikev1.'ike-crypto-profile') {
                $Object.IkeV1Enabled = $true
                $Object.IkeCryptoProfile = $entry.protocol.ikev1.'ike-crypto-profile'
            }

            $Object.Interface = [HelperXml]::parseCandidateConfigXml($entry.'local-address'.interface, $false)
            $Object.LocalIPAddress = [HelperXml]::parseCandidateConfigXml($entry.'local-address'.ip, $false)

            $Object.PeerIpAddress = [HelperXml]::parseCandidateConfigXml($entry.'peer-address'.ip, $false)
        }

        $ReturnObject
    }
}