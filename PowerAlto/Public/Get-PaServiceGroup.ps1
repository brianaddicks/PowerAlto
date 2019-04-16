function Get-PaServiceGroup {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Get-PaServiceGroup:"
        $XPathNode = 'service-group'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $Name)
    }

    PROCESS {
        if ($null -ne $Global:PaDeviceObject.Config) {
            $Entries = $global:PaDeviceObject.Config.config.devices.entry.vsys.entry.$XPathNode.entry
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
            $Object = [PaServiceGroup]::new($entry.name)
            $ReturnObject += $Object

            # Add Members
            $Object.Member += $entry.members.member

            # Add Tags
            $Object.Tags = [HelperXml]::parseCandidateConfigXml($entry.tag.member, $false)
        }

        $ReturnObject
    }
}