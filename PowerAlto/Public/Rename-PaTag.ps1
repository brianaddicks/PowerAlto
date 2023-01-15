function Rename-PaTag {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Name,
		[Parameter(Mandatory = $True, Position = 1)]
        [string]$NewName
    )

    BEGIN {
        $XPathNode = 'tag'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $Name)
    }

    PROCESS {
        $Rename = Invoke-PaApiConfig -Rename -Xpath $XPath -Element $NewName
		$Rename
    }
}