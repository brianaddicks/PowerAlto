function Set-PaTargetVsys {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Name
    )

    BEGIN {
    }

    PROCESS {
        if ($global:PaDeviceObject.Connected) {
            if ($global:PaDeviceObject.VsysEnabled -eq $false) {
                Throw "Multi-Vsys capabilities not enabled on $($global:PaDeviceObject.Hostname)"
            }
            $global:PaDeviceObject.TargetVsys = $Name
        } else {
            Throw "No Palo Alto Device connected.  Use Get-PaDevice to initiate a connection."
        }
    }
}