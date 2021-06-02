function Set-PaTargetDeviceGroup {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Name
    )

    BEGIN {
    }

    PROCESS {
        if ($global:PaDeviceObject.Connected) {
            if ($global:PaDeviceObject.Model -ne 'Panorama') {
                Throw "$($global:PaDeviceObject.Hostname) is not a Panorama device"
            }
            if ($Name -eq 'shared') {
                $global:PaDeviceObject.TargetDeviceGroup = $null
            } else {
                $global:PaDeviceObject.TargetDeviceGroup = $Name
            }
        } else {
            Throw "No Palo Alto Device connected.  Use Get-PaDevice to initiate a connection."
        }
    }
}