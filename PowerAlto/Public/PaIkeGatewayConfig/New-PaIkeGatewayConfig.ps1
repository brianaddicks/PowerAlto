function New-PaIkeGatewayConfig {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "New-PaIkeGatewayConfig:"
    }

    PROCESS {
        $ReturnObject = [PaIkeGatewayConfig]::new()

        if ($Name) {
            $ReturnObject.Name = $Name
        }
    }

    END {
        $ReturnObject
    }
}
