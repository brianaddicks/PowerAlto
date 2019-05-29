enum HaMode {
    ActivePassive
    ActiveActive
}

class PaHaSetup {
    # non-static properties
    [bool]$Enabled
    [int]$GroupId
    [string]$Description
    [HaMode]$Mode = 'ActivePassive'
    [int]$DeviceId
    [bool]$EnableConfigSync = $true
    [string]$PeerHa1IpAddress
    [string]$BackupPeerHa1IpAddress

    # static properties
    static [string]$XPathNode = 'deviceconfig/high-availability'

    #region ToXml
    ######################################################################################

    # invokeReportGetQuery
    [Xml] ToXml() {
        # parent doc
        [xml]$Doc = New-Object System.Xml.XmlDocument
        $root = $Doc.CreateNode("element", "high-availability", $null)

        #region group
        ###########################################################################

        # group node
        $GroupNode = $Doc.CreateNode("element", "group", $null)
        $AddGroupNode = $false

        # GroupId
        if ($this.GroupId) {
            $ChildNode = $Doc.CreateNode("element", "group-id", $null)
            $ChildNode.InnerText = $this.GroupId
            $GroupNode.AppendChild($ChildNode)
            $AddGroupNode = $true
        }

        # Description
        if ($this.Description) {
            $ChildNode = $Doc.CreateNode("element", "description", $null)
            $ChildNode.InnerText = $this.Description
            $GroupNode.AppendChild($ChildNode)
            $AddGroupNode = $true
        }

        # PeerHa1IpAddress
        if ($this.PeerHa1IpAddress) {
            $ChildNode = $Doc.CreateNode("element", "peer-ip", $null)
            $ChildNode.InnerText = $this.PeerHa1IpAddress
            $GroupNode.AppendChild($ChildNode)
            $AddGroupNode = $true
        }

        # BackupPeerHa1IpAddress
        if ($this.BackupPeerHa1IpAddress) {
            $ChildNode = $Doc.CreateNode("element", "peer-ip-backup", $null)
            $ChildNode.InnerText = $this.BackupPeerHa1IpAddress
            $GroupNode.AppendChild($ChildNode)
            $AddGroupNode = $true
        }

        # EnableConfigSync
        if (!($this.EnableConfigSync)) {
            $ChildNode = $Doc.CreateNode("element", "configuration-synchronization", $null)
            $ChildSubNode = $Doc.CreateNode("element", "enabled", $null)
            $ChildSubNode.InnerText = 'no'
            $ChildNode.AppendChild($ChildSubNode)
            $GroupNode.AppendChild($ChildNode)
            $AddGroupNode = $true
        }

        # ActiveActive
        if ($this.Mode -eq 'ActiveActive') {
            $ChildNode = $Doc.CreateNode("element", "mode", $null)
            $ChildSubNode = $Doc.CreateNode("element", "active-active", $null)
            $ChildSubSubNode = $Doc.CreateNode("element", "device-id", $null)
            $ChildSubSubNode.InnerText = 'DeviceId'
            $ChildSubNode.AppendChild($ChildSubSubNode)
            $ChildNode.AppendChild($ChildSubNode)
            $GroupNode.AppendChild($ChildNode)
            $AddGroupNode = $true
        }

        if ($AddGroupNode) {
            $root.AppendChild($GroupNode)
        }

        ###########################################################################
        #endregion group

        #region enabled
        ###########################################################################

        # Enabled
        if ($this.Enabled) {
            $ChildNode = $Doc.CreateNode("element", "enabled", $null)
            $ChildNode.InnerText = 'yes'
            $root.AppendChild($ChildNode)
        }

        ###########################################################################
        #endregion enabled

        #region setting-management
        ###########################################################################

        $AddManagementNode = $false

        # system node
        $SettingNode = $Doc.CreateNode("element", "setting", $null)

        # management node
        $ManagementNode = $Doc.CreateNode("element", "management", $null)

        # EnableDeviceMonitoring
        if (!($this.EnableDeviceMonitoring)) {
            $DeviceMonitoringNode = $Doc.CreateNode("element", "device-monitoring", $null)
            $EnabledNode = $Doc.CreateNode("element", "enabled", $null)
            $EnabledNode.InnerText = 'no'
            $DeviceMonitoringNode.AppendChild($EnabledNode)
            $ManagementNode.AppendChild($DeviceMonitoringNode)
            $AddManagementNode = $true
        }

        # ReceiveTimeout
        if ($this.ReceiveTimeout -ne 240) {
            $ReceiveTimeoutNode = $Doc.CreateNode("element", "panorama-tcp-receive-timeout", $null)
            $ReceiveTimeoutNode.InnerText = $this.ReceiveTimeout
            $ManagementNode.AppendChild($ReceiveTimeoutNode)
            $AddManagementNode = $true
        }

        # SendTimeout
        if ($this.SendTimeout -ne 240) {
            $SendTimeoutNode = $Doc.CreateNode("element", "panorama-tcp-send-timeout", $null)
            $SendTimeoutNode.InnerText = $this.SendTimeout
            $ManagementNode.AppendChild($SendTimeoutNode)
            $AddManagementNode = $true
        }

        # RetryCount
        if ($this.RetryCount -ne 25) {
            $RetryCountNode = $Doc.CreateNode("element", "panorama-ssl-send-retries", $null)
            $RetryCountNode.InnerText = $this.RetryCount
            $ManagementNode.AppendChild($RetryCountNode)
            $AddManagementNode = $true
        }

        if ($AddManagementNode) {
            $SettingNode.AppendChild($ManagementNode)
            $root.AppendChild($SettingNode)
        }

        ###########################################################################
        #endregion setting-management

        $Doc.AppendChild($root)

        return $Doc
    }

    ######################################################################################
    #region ToXml

    ##################################### Initiators #####################################
    # Initiator
    PaHaSetup() {
    }
}