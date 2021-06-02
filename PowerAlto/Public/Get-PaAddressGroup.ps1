function Get-PaAddressGroup {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Get-PaAddressGroup:"
        $XPathNode = 'address-group'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $Name)
    }

    PROCESS {
        if ($null -ne $Global:PaDeviceObject.Config) {
            $Entries = $global:PaDeviceObject.Config.config.devices.entry.vsys.entry.'address-group'.entry
        } else {
            $Response = Invoke-PaApiConfig -Get -Xpath $XPath
            if ($Response.response.result.$XPathNode) {
                $Entries = $Response.response.result.$XPathNode.entry
            } else {
                $Entries = $Response.response.result.entry
            }
        }

        $ReturnObject = @()
        foreach ($entry in $Entries) {
            # Initialize Report object, add to returned array
            $Object = [PaAddressGroup]::new($entry.name)
            $ReturnObject += $Object

            # Type and Value
            if ($entry.static) {
                $Object.Type = 'static'
                $Object.Member += $entry.static.member
            } elseif ($entry.dynamic) {
                $Object.Type = 'dynamic'
                $Object.Filter += $entry.dynamic.filter
            }

            # Add other properties to report
            $Object.Description = [HelperXml]::parseCandidateConfigXml($entry.description, $false)
            $Object.Tags = [HelperXml]::parseCandidateConfigXml($entry.tag.member, $false)
        }

        $ReturnObject
    }
}