function Get-PaAddress {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory = $False)]
        [switch]$ShowAll,

        [Parameter(Mandatory = $false)]
        [switch]$PushedSharedPolicy
    )

    BEGIN {
        $VerbosePrefix = "Get-PaAddress:"
        $ResponseNode = 'address'
        $Xpath = $Global:PaDeviceObject.createXPath($ResponseNode, $Name)
    }

    PROCESS {
        if ($Global:PaDeviceObject.Model -eq 'Panorama' -and $ShowAll) {
            $CurrentDeviceGroup = $Global:PaDeviceObject.TargetDeviceGroup
            if ($null -eq $CurrentDeviceGroup) {
                $CurrentDeviceGroup = 'shared'
            }
            $DeviceGroups = Get-PaDeviceGroup
            $ReturnObject = Get-PaAddress
            foreach ($dg in $DeviceGroups) {
                Set-PaTargetDeviceGroup -Name $dg.Name
                $ReturnObject += Get-PaAddress
            }
            Set-PaTargetDeviceGroup -Name $CurrentDeviceGroup
        } else {
            if ($null -ne $Global:PaDeviceObject.Config) {
                $Entries = $global:PaDeviceObject.Config.config.devices.entry.vsys.entry.address.entry
            } else {
                if ($PushedSharedPolicy) {
                    $PushedSharedPolicyResponse = Invoke-PaApiOperation '<show><config><pushed-shared-policy></pushed-shared-policy></config></show>'
                    $PushedSharedPolicyResponse = $PushedSharedPolicyResponse.response.result.policy.panorama.address.entry
                }

                $Response = Invoke-PaApiConfig -Get -Xpath $XPath

                if ($Response.response.result.$ResponseNode) {
                    $Entries = $Response.response.result.$ResponseNode.entry
                } else {
                    $Entries = $Response.response.result.entry
                }

                $AllEntries = @()

                foreach($rulebase in @($PushedSharedPolicyResponse,$Entries)) {
                    foreach ($entry in $rulebase) {
                        $AllEntries += $entry
                    }
                }
                $global:ptest = $AllEntries
            }

            $ReturnObject = @()
            foreach ($entry in $AllEntries) {
                # Initialize Report object, add to returned array
                $Object = [PaAddress]::new($entry.name)
                $Object.Vsys = $Global:PaDeviceObject.TargetVsys
                $Object.DeviceGroup = $Global:PaDeviceObject.TargetDeviceGroup

                if ([string]::IsNullOrEmpty($Object.DeviceGroup) -and ($Global:PaDeviceObject.Model -eq 'Panorama')) {
                    $Object.DeviceGroup = 'shared'
                }

                $ReturnObject += $Object

                # Type and Value
                if ($entry.'ip-netmask') {
                    $Object.Type = 'ip-netmask'
                    $Object.Value = [HelperXml]::parseCandidateConfigXml($entry.'ip-netmask', $false)
                } elseif ($entry.'ip-range') {
                    $Object.Type = 'ip-range'
                    $Object.Value = [HelperXml]::parseCandidateConfigXml($entry.'ip-range', $false)
                } elseif ($entry.fqdn) {
                    $Object.Type = 'fqdn'
                    $Object.Value = [HelperXml]::parseCandidateConfigXml($entry.'fqdn', $false)
                }

                # Add other properties to report
                $Object.Description = [HelperXml]::parseCandidateConfigXml($entry.description, $false)
                $Object.Tags = [HelperXml]::GetMembersFromXml($entry.tag)
            }
        }

        $ReturnObject
    }
}