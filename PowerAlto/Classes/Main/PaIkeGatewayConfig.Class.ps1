Class PaIkeGatewayConfig {
    [string]$Name
    [bool]$IkeV1Enabled
    [bool]$IkeV2Enabled

    [string]$Interface
    [string]$LocalIPAddress

    [string]$PeerIpAddress

    [string]$IkeCryptoProfile

    #region Initiators
    ########################################################################

    # empty initiator
    PaIkeGatewayConfig() {
    }

    ########################################################################
    #endregion Initiators
}
