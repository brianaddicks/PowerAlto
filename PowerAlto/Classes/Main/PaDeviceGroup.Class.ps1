Class PaDeviceGroup {
    [string]$Name
    [string]$Description
    [string[]]$ReferenceTemplate
    [string[]]$Device
    [string]$ParentDeviceGroup
    [string]$MasterDeviceGroup

    #region Initiators
    ########################################################################

    # empty initiator
    PaDeviceGroup() {
    }

    # with name
    PaDeviceGroup([string]$Name) {
        $this.Name = $Name
    }

    ########################################################################
    #endregion Initiators
}
