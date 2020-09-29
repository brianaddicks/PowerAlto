function Restart-PaIpsecTunnel {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Restart-PaIpsecTunnel:"
    }

    PROCESS {
        $IpsecConfig = Get-PaIpsecTunnelConfig -Name $Name

        if ($IpsecConfig) {
            $IkeConfig = Get-PaIkeGatewayConfig -Name $IpsecConfig.IkeGateway

            # Clear each IPSEC connection
            if ($IpsecConfig.ProxyId.Count -gt 0) {
                foreach ($proxyid in $IpsecConfig.ProxyId) {
                    $ThisTunnelName = $Name + ':' + $proxyid.Name
                    Clear-PaIpsecTunnel -Name $ThisTunnelName
                }
            } else {
                Clear-PaIpsecTunnel -Name $Name
            }

            # Clear IKE connection
            Clear-PaIkeGateway -Name $IpsecConfig.IkeGateway

            Test-PaIkeGateway -Name $Name
            foreach ($proxyid in $IpsecConfig.ProxyId) {
                $ThisTunnelName = $Name + ':' + $proxyid.Name
                Test-PaIpsecTunnel -Name $ThisTunnelName
            }
        } else {
            Throw "No Ipsec Tunnel found with Name: $Name"
        }
    }

    END {
    }
}