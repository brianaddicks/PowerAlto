Class PaIpsecTunnel {
    [string]$Name
    [int]$Id
    [string]$State
    [bool]$Monitor
    [string]$LocalIp
    [string]$PeerIp
    [string]$TunnelInterface

    #region Initiators
    ########################################################################

    # empty initiator
    PaIpsecTunnel() {
    }

    ########################################################################
    #endregion Initiators
}
