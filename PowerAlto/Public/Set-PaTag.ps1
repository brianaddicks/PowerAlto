function Set-PaTag {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ParameterSetName = "name", Mandatory = $True, Position = 0)]
        [string]$Name,

        [Parameter(ParameterSetName = "name", Mandatory = $False, Position = 1)]
        [ValidateSet('Red', 'Green', 'Blue', 'Yellow', 'Copper', 'Orange', 'Purple', 'Gray', 'Light Green', 'Cyan', 'Light Gray', 'Blue Gray', 'Lime', 'Black', 'Gold', 'Brown', 'Olive', 'Maroon', 'Red-Orange', 'Yellow-Orange', 'Forest Green', 'Turquoise Blue', 'Azure Blue', 'Cerulean Blue', 'Midnight Blue', 'Medium Blue', 'Cobalt Blue', 'Violet Blue', 'Blue Violet', 'Medium Violet', 'Medium Rose', 'Lavender', 'Orchid', 'Thistle', 'Peach', 'Salmon', 'Magenta', 'Red Violet', 'Mahogany', 'Burnt Sienna', 'Chestnut')]
        [string]$Color,

        [Parameter(ParameterSetName = "name", Mandatory = $False, Position = 2)]
        [string]$Comments,

        [Parameter(ValueFromPipeline, ParameterSetName = "PaTag", Mandatory = $True, Position = 0)]
        [PaTag]$PaTag
    )

    BEGIN {
        $ConfigNode = 'tag'
    }

    PROCESS {

        switch ($PsCmdlet.ParameterSetName) {
            'name' {
                if ($Color) {
                    $ConfigObject = [PaTag]::new($Name, $Color)
                } else {
                    $ConfigObject = [PaTag]::new($Name)
                }

                $ConfigObject.Comments = $Comments
                continue
            }
            'PaTag' {
                $ConfigObject = $PaTag
                continue
            }
        }



        $ElementXml = $ConfigObject.ToXml().$ConfigNode.entry.InnerXml
        $Xpath = $Global:PaDeviceObject.createXPath($ConfigNode, $ConfigObject.Name)

        if ($PSCmdlet.ShouldProcess("Creating new Tag: $($ConfigObject.Name)")) {
            $Set = Invoke-PaApiConfig -Set -Xpath $XPath -Element $ElementXml

            $Set
        }
    }
}