class PaPanoramaConfig {
    # non-static properties
    [string]$PrimaryServer
    [string]$SecondaryServer
    [bool]$EnableDeviceMonitoring = $true
    [int]$ReceiveTimeout = 240
    [int]$SendTimeout = 240
    [int]$RetryCount = 25

    # static properties
    static [string]$XPathNode = 'deviceconfig'

    #region ToXml
    ######################################################################################

    # invokeReportGetQuery
    [Xml] ToXml() {
        # parent doc
        [xml]$Doc = New-Object System.Xml.XmlDocument
        $root = $Doc.CreateNode("element", "deviceconfig", $null)

        #region system
        ###########################################################################

        # system node
        $SystemNode = $Doc.CreateNode("element", "system", $null)

        if ($this.PrimaryServer) {
            # primary panorama server
            $PrimaryPanoramaNode = $Doc.CreateNode("element", "panorama-server", $null)
            $PrimaryPanoramaNode.InnerText = $this.PrimaryServer
            $SystemNode.AppendChild($PrimaryPanoramaNode)
        }

        if ($this.SecondaryServer) {
            # primary panorama server
            $SecondaryPanoramaNode = $Doc.CreateNode("element", "panorama-server-2", $null)
            $SecondaryPanoramaNode.InnerText = $this.SecondaryServer
            $SystemNode.AppendChild($SecondaryPanoramaNode)
        }

        if ($this.SecondaryServer -or $this.PrimaryServer) {
            $root.AppendChild($SystemNode)
        }

        ###########################################################################
        #endregion system

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
    PaPanoramaConfig() {
    }
}