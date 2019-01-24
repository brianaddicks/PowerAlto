function Set-PaTag {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateSet('Red', 'Green', 'Blue', 'Yellow', 'Copper', 'Orange', 'Purple', 'Gray', 'Light Green', 'Cyan', 'Light Gray', 'Blue Gray', 'Lime', 'Black', 'Gold', 'Brown', 'Green')]
        [string]$Color,

        [Parameter(Mandatory = $False, Position = 2)]
        [string]$Comments
    )

    BEGIN {
        $ConfigNode = 'tag'
        $Xpath = $Global:PaDeviceObject.createXPath($ConfigNode, $Name)
    }

    PROCESS {

        if ($Color) {
            $ConfigObject = [PaTag]::new($Name, $Color)
            $global:configobject = $ConfigObject
        } else {
            $ConfigObject = [PaTag]::new($Name)
        }

        $ConfigObject.Comments = $Comments

        $ElementXml = $ConfigObject.ToXml().$ConfigNode.entry.InnerXml

        if ($PSCmdlet.ShouldProcess("Creating new Tag: $($ConfigObject.Name)")) {
            $Set = Invoke-PaApiConfig -Set -Xpath $XPath -Element $ElementXml

            $Set
        }
    }
}