function Get-PaInterface {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Get-PaInterface:"
        $XPathNode = [PaInterface]::XPathNode
        $ReponseNode = [PaInterface]::ReponseNode
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $null)

        $InterfaceTypes = @()
        $InterfaceTypes += 'ethernet'
        $InterfaceTypes += 'loopback'
        $InterfaceTypes += 'vlan'
        $InterfaceTypes += 'tunnel'
        $InterfaceTypes += 'aggregate-ethernet'
    }

    PROCESS {
        $Response = Invoke-PaApiConfig -Get -Xpath $XPath

        $ReturnObject = @()
        foreach ($type in $InterfaceTypes) {
            $Entries = $Response.response.result.interface.$type.entry
            foreach ($entry in $Entries) {
                # Initialize Report object, add to returned array
                $Object = [PaInterface]::new($entry.name)
                $ReturnObject += $Object
            }
        }

        $ReturnObject
    }
}