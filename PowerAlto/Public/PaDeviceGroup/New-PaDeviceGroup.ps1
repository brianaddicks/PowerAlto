function New-PaDeviceGroup {
    [CmdletBinding()]
    Param (
    )

    BEGIN {
        $VerbosePrefix = "New-PaDeviceGroup:"
    }

    PROCESS {
        $ReturnObject = [PaDeviceGroup]::new()
    }

    END {
        $ReturnObject
    }
}
