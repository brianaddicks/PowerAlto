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

                $Object.comment = $entry.comment

                switch ($type) {
                    'ethernet' {
                        if ($entry.'aggregate-group') {
                            $Object.Type = 'AggregateEthernet'
                            $Object.AggregateGroup = $entry.'aggregate-group'
                        }
                        if ($entry.layer3) {
                            $Object.Type = 'Layer3'

                            # pppoe
                            if ($entry.layer3.pppoe) {
                                $Object.Type += 'PPPoE'
                                if ($entry.layer3.pppoe.'static-address') {
                                    $Object.IpAddress = $entry.layer3.pppoe.'static-address'.ip
                                }
                            }

                            # normal interface
                            if ($entry.layer3.ip) {
                                $Object.IpAddress = $entry.layer3.ip.entry.name
                            }

                            # subinterface
                            if ($entry.layer3.units) {
                                foreach ($subinterface in $entry.layer3.units.entry) {
                                    $SubObject = [PaInterface]::new($subinterface.name)
                                    $SubObject.Type = 'Layer3Subinterface'
                                    $SubObject.Tag = $subinterface.Tag
                                    $SubObject.IpAddress = $subinterface.ip.entry.name
                                    $SubObject.Comment = $subinterface.comment

                                    $ReturnObject += $SubObject
                                }
                            }
                        }
                    }
                }


                $ReturnObject += $Object
            }
        }

        $ReturnObject
    }
}