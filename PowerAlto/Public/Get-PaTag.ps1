function Get-PaTag {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Get-PaTag:"
        $XPathNode = 'tag'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $Name)
    }

    PROCESS {
        # Get the config info for the tag
        # This is required for the call to run the tag
        $Response = Invoke-PaApiConfig -Get -Xpath $XPath
        if ($Response.response.result.$XPathNode) {
            $Entries = $Response.response.result.$XPathNode.entry
        } else {
            $Entries = $Response.response.result.entry
        }

        $ReturnObject = @()
        foreach ($entry in $Entries) {
            # Initialize object, add to returned array
            if ($entry.color) {
                $Color = $entry.color
                $Object = [PaTag]::new($entry.name, $Color)
            } else {
                $Object = [PaTag]::new($entry.name)
            }

            $ReturnObject += $Object

            # Add other properties to object
            $Object.Comments = $entry.comments
        }

        $ReturnObject
    }
}