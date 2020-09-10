class PaProxyId {
    [string]$Name
    [string]$Protocol = 'any'
    [string]$LocalNetwork
    [string]$RemoteNetwork

    ###################################### Methods #######################################

    ##################################### Initiators #####################################
    # Initiator
    PaProxyId([string]$Name) {
        $this.Name = $Name
    }
}