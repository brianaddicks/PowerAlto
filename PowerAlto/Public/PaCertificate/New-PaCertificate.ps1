<# function New-PaCertificate {
    [CmdletBinding()]
    Param (
    )

    BEGIN {
        $VerbosePrefix = "New-PaCertificate:"
    }

    PROCESS {
        $ReturnObject = [PaCertificate]::new()
    }

    END {
        $ReturnObject
    }
}
 #>