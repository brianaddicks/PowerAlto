function Get-PaPanoramaConfig {
    [CmdletBinding()]
    Param (
    )

    BEGIN {
        $VerbosePrefix = "Get-PaPanoramaConfig:"
        $ConfigObject = [PaPanoramaConfig]::new()
        $XPathNode = $ConfigObject::XPathNode
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $null)
    }

    PROCESS {
        $Response = Invoke-PaApiConfig -Get -Xpath $XPath
        $Result = $Response.response.result.$XPathNode

        $ConfigObject.PrimaryServer = [HelperXml]::parseCandidateConfigXml($Result.system.'panorama-server', $false)
        $ConfigObject.SecondaryServer = [HelperXml]::parseCandidateConfigXml($Result.system.'panorama-server-2', $false)
        $ConfigObject.ReceiveTimeout = [HelperXml]::parseCandidateConfigXml($Result.setting.'management'.'panorama-tcp-receive-timeout', $false)
        $ConfigObject.SendTimeout = [HelperXml]::parseCandidateConfigXml($Result.setting.'management'.'panorama-tcp-send-timeout', $false)
        $ConfigObject.RetryCount = [HelperXml]::parseCandidateConfigXml($Result.setting.'management'.'panorama-ssl-send-retries', $false)

        $DeviceMonitoring = [HelperXml]::parseCandidateConfigXml($Result.setting.'management'.'device-monitoring'.enabled, $false)

        if ($DeviceMonitoring -eq 'no') {
            $ConfigObject.EnableDeviceMonitoring = $false
        } else {
            $ConfigObject.EnableDeviceMonitoring = $true
        }

        $ConfigObject
    }
}