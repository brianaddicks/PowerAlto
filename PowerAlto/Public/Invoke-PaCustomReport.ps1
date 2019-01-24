function Invoke-PaCustomReport {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory = $False)]
        [switch]$ShowProgress
    )

    BEGIN {
        $VerbosePrefix = "Invoke-PaCustomReport:"

        $VerbosePrefix = "Get-PaAddress:"
        $XPathNode = 'reports'
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $Name)
    }

    PROCESS {
        # Get the config info for the report
        # This is required for the call to run the report
        $ReportConfig = Invoke-PaApiConfig -Get -Xpath $Xpath
        if ($ReportConfig.response.result -eq "") {
            Throw "$VerbosePrefix Report not found: $Name"
        }

        # Extract the required xml
        $ReportXml = $ReportConfig.response.result.entry.InnerXml

        # Initiate the Report Job
        $ReportParams = @{}
        $ReportParams.ReportType = 'dynamic'
        $ReportParams.ReportName = $Name
        $ReportParams.Cmd = $ReportXml
        $ReportResults = Invoke-PaApiReport @ReportParams
        $JobId = $ReportResults.response.result.job

        # https://<firewall>/api/?type=report&action=get&job-id=jobid

        $GetJob = Get-PaReportJob -JobId $JobId -Wait -ShowProgress:$ShowProgress

        return $GetJob
    }
}