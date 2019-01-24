function Get-PaUrlCategory {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Get-PaUrlCategory:"
        $XPathNode = 'profiles/custom-url-category'
        $ResponseNode = 'custom-url-category'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $Name)
    }

    PROCESS {
        # Get the config info for the tag
        # This is required for the call to run the tag
        $Response = Invoke-PaApiConfig -Get -Xpath $XPath
        if ($Response.response.result.$ResponseNode) {
            $Entries = $Response.response.result.$ResponseNode.entry
        } else {
            $Entries = $Response.response.result.entry
        }

        $ReturnObject = @()
        foreach ($entry in $Entries) {
            # Initialize object, add to returned array
            $Object = [PaUrlCategory]::new($entry.name)
            $ReturnObject += $Object

            # Add other properties to object
            $Object.Description = [HelperXml]::parseCandidateConfigXml($entry.description, $false)
            $Object.Members = [HelperXml]::GetMembersFromXml($entry.list)
        }

        $ReturnObject
    }
}