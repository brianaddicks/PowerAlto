function Get-PaDeviceGroup {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Get-PaDeviceGroup:"
        $XPathNode = 'device-group'
        $ResultNode = 'device-group'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $Name)
    }

    PROCESS {
        $Response = Invoke-PaApiConfig -Get -Xpath $XPath
        if ($Response.response.result.$ResultNode) {
            $Entries = $Response.response.result.$ResultNode.entry
        } else {
            $Entries = $Response.response.result.entry
        }

        $ReturnObject = @()
        foreach ($entry in $Entries) {
            # Initialize Report object, add to returned array
            $Object = [PaDeviceGroup]::new($entry.name)
            $ReturnObject += $Object

            $Object.Description = [HelperXml]::parseCandidateConfigXml($entry.description, $false)
            foreach ($device in $entry.devices.entry) {
                $Object.Device += [HelperXml]::parseCandidateConfigXml($device.name, $false)
            }
        }

        $ReturnObject
    }


}
