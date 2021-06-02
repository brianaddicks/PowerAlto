class PaIpsecTunnelConfig {
    [string]$Name
    [string]$IkeGateway
    [string]$IpsecCryptoProfile
    [string]$TunnelInterface
    [bool]$Disabled

    [array]$ProxyId

    ###################################### Methods #######################################

    ##################################### Initiators #####################################
    # Initiator
    PaIpsecTunnelConfig([string]$Name) {
        $this.Name = $Name
    }
}