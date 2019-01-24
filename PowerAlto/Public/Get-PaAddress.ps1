function Get-PaAddress {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Get-PaAddress:"
        $XPathNode = 'address'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $Name)
    }

    PROCESS {
        # Get the config info for the report
        # This is required for the call to run the report
        $Response = Invoke-PaApiConfig -Get -Xpath $XPath
        if ($Response.response.result.$XPathNode) {
            $Entries = $Response.response.result.$XPathNode.entry
        } else {
            $Entries = $Response.response.result.entry
        }

        $ReturnObject = @()
        foreach ($entry in $Entries) {
            # Initialize Report object, add to returned array
            $Object = [PaAddress]::new($entry.name)
            $ReturnObject += $Object

            # Type and Value
            if ($entry.'ip-netmask') {
                $Object.Type = 'ip-netmask'
                $Object.Value = $entry.'ip-netmask'
            } elseif ($entry.'ip-range') {
                $Object.Type = 'ip-range'
                $Object.Value = $entry.'ip-range'
            } elseif ($entry.fqdn) {
                $Object.Type = 'fqdn'
                $Object.Value = $entry.'fqdn'
            }

            # Add other properties to report
            $Object.Description = [HelperXml]::parseCandidateConfigXml($entry.description, $false)
            $Object.Tags = [HelperXml]::GetMembersFromXml($entry.tag)
        }

        $ReturnObject
    }
}