function Get-PaHaSetup {
    [CmdletBinding()]
    Param (
    )

    BEGIN {
        $VerbosePrefix = "Get-PaHaSetup:"
        $ConfigObject = [PaHaSetup]::new()
        $XPathNode = $ConfigObject::XPathNode
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $null)
    }

    PROCESS {
        $Response = Invoke-PaApiConfig -Get -Xpath $XPath
        $Result = $Response.response.result
        $LastXPathNode = ($XPathNode.Split('/'))[-1]
        $Result = $Result.$LastXPathNode

        if ([HelperXml]::parseCandidateConfigXml($Result.enabled, $false) -eq 'yes') {
            $ConfigObject.Enabled = $true
        }

        $ConfigObject.GroupId = [HelperXml]::parseCandidateConfigXml($Result.group.'group-id', $false)
        $ConfigObject.Description = [HelperXml]::parseCandidateConfigXml($Result.group.'description', $false)
        $ConfigObject.PeerHa1IpAddress = [HelperXml]::parseCandidateConfigXml($Result.group.'peer-ip', $false)
        $ConfigObject.BackupPeerHa1IpAddress = [HelperXml]::parseCandidateConfigXml($Result.group.'peer-ip-backup', $false)

        if ([HelperXml]::parseCandidateConfigXml($Result.'configuration-synchronization'.enabled, $false) -eq 'no') {
            $ConfigObject.Enabled = $false
        }

        if ([HelperXml]::parseCandidateConfigXml($Result.'mode'.'active-active'.'device-id', $false)) {
            $ConfigObject.Mode = 'ActiveActive'
            $ConfigObject.DeviceId = [HelperXml]::parseCandidateConfigXml($Result.'mode'.'active-active'.'device-id', $false)
        }

        $ConfigObject
    }
}