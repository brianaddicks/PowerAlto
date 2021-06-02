function Invoke-PaApiReport {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$ReportType,

        [Parameter(Mandatory = $True, Position = 1)]
        [string]$ReportName,

        [Parameter(Mandatory = $True, Position = 2)]
        [string]$Cmd
    )

    BEGIN {
        $VerbosePrefix = "Invoke-PaApiReport:"
    }

    PROCESS {
        $Global:PaDeviceObject.invokeReportQuery($ReportType, $ReportName, $Cmd)
    }
}