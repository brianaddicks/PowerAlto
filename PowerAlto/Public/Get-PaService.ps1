function Get-PaService {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Get-PaService:"
        $XPathNode = 'service'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $Name)
    }

    PROCESS {
        if ($null -ne $Global:PaDeviceObject.Config) {
            $Entries = $global:PaDeviceObject.Config.config.devices.entry.vsys.entry.service.entry
        } else {
            $Response = Invoke-PaApiConfig -Get -Xpath $XPath
            if ($Response.response.result.$XPathNode) {
                $Entries = $Response.response.result.$XPathNode.entry
            } else {
                $Entries = $Response.response.result.entry
            }
        }

        $ReturnObject = @()

        # add default services
        $Object = [PaService]::new('service-http')
        $Object.Protocol = 'tcp'
        $Object.DestinationPort = '80'
        $ReturnObject += $Object

        $Object = [PaService]::new('service-https')
        $Object.Protocol = 'tcp'
        $Object.DestinationPort = '443'
        $ReturnObject += $Object

        foreach ($entry in $Entries) {
            # Initialize Report object, add to returned array
            $Object = [PaService]::new($entry.name)
            $ReturnObject += $Object

            # Get protocol
            if ($entry.protocol.tcp) {
                $Protocol = 'tcp'
            } elseif ($entry.protocol.udp) {
                $Protocol = 'udp'
            }

            $Object.Protocol = $Protocol
            $Object.SourcePort = $entry.protocol.$Protocol.'source-port'
            $Object.DestinationPort = $entry.protocol.$Protocol.'port'

            #TODO: add $protocol.override

            # Add other properties to report
            $Object.Description = [HelperXml]::parseCandidateConfigXml($entry.description, $false)
            $Object.Tags = [HelperXml]::GetMembersFromXml($entry.tag)
        }

        $ReturnObject
    }
}