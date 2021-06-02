function Get-PaIpsecTunnelConfig {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Get-PaIpsecTunnelConfig:"
        $XPathNode = 'network/tunnel/ipsec'
        $ResultNode = 'ipsec'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $Name)
    }

    PROCESS {
        $Response = Invoke-PaApiConfig -Get -Xpath $XPath
        if ($Response.response.result.$ResultNode) {
            $Entries = $Response.response.result.$ResultNode.entry
        } else {
            $Entries = $Response.response.result.entry
        }

        $ReturnObject = @()
        foreach ($entry in $Entries) {
            # Initialize Report object, add to returned array
            $Object = [PaIpsecTunnelConfig]::new($entry.name)
            $ReturnObject += $Object

            # disabled
            $Disabled = [HelperXml]::parseCandidateConfigXml($entry.disabled, $false)
            if ($Disabled -eq 'yes') {
                $Object.Disabled = $true
            }

            # Add other properties
            $Object.IkeGateway = [HelperXml]::parseCandidateConfigXml($entry.'auto-key'.'ike-gateway'.entry.name, $false)
            $Object.IpsecCryptoProfile = [HelperXml]::parseCandidateConfigXml($entry.'auto-key'.'ipsec-crypto-profile', $false)
            $Object.TunnelInterface = [HelperXml]::parseCandidateConfigXml($entry.'tunnel-interface', $false)

            foreach ($proxyid in $entry.'auto-key'.'proxy-id'.entry) {
                $NewProxyId = [PaProxyId]::new($proxyid.name)
                $NewProxyId.LocalNetwork = $proxyid.local
                $NewProxyId.RemoteNetwork = $proxyid.remote

                $Object.ProxyId += $NewProxyId
            }
        }

        $ReturnObject
    }
}