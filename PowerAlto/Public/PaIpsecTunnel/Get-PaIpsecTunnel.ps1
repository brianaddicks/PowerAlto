function Get-PaIpsecTunnel {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Get-PaIpsecTunnel:"
        $ReturnObject = @()
    }

    PROCESS {
        $Cmd = "<show><vpn><ipsec-sa><tunnel>$Name</tunnel></ipsec-sa></vpn></show>"

        $CommandBeingRun = [regex]::split($Cmd, '[<>\/]+') | Select-Object -Unique | Where-Object { $_ -ne "" }
        if ($PSCmdlet.ShouldProcess("Running Operational Command: $CommandBeingRun")) {
            $Response = Invoke-PaApiOperation -Cmd $Cmd
        }

        $Entries = $Response.response.result.entries.entry

        foreach ($entry in $Entries) {
            # Initialize Report object, add to returned array
            $Object = New-PaIpsecTunnel
            $ReturnObject += $Object

            $Object.Name = $entry.Name
            $Object.Id = $entry.gwid
            $Object.PeerIp = $entry.remote
            $Object.TunnelInterface = $entry.tid

        }
    }

    END {
        $ReturnObject
    }
}