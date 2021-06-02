function New-PaIpsecTunnel {
    [CmdletBinding()]
    Param (
    )

    BEGIN {
        $VerbosePrefix = "New-PaIpsecTunnel:"
    }

    PROCESS {
        $ReturnObject = [PaIpsecTunnel]::new()
    }

    END {
        $ReturnObject
    }
}
