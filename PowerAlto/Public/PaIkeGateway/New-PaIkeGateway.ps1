function New-PaIkeGateway {
    [CmdletBinding()]
    Param (
    )

    BEGIN {
        $VerbosePrefix = "New-PaIkeGateway:"
    }

    PROCESS {
        $ReturnObject = [PaIkeGateway]::new()
    }

    END {
        $ReturnObject
    }
}
