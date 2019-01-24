function Get-PaCustomReport {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory = $False, Position = 1)]
        [string]$Vsys
    )

    BEGIN {
        $VerbosePrefix = "Get-PaCustomReport:"
        $Xpath = $Global:PaDeviceObject.createXPath('reports', $Name)
    }

    PROCESS {
        # Get the config info for the report
        # This is required for the call to run the report
        $ReportConfig = Invoke-PaApiConfig -Get -Xpath $XPath
        if ($ReportConfig.response.result.reports) {
            $Entries = $ReportConfig.response.result.reports.entry
        } else {
            $Entries = $ReportConfig.response.result.entry
        }

        $ReturnObject = @()
        foreach ($entry in $Entries) {
            # Initialize Report object, add to returned array
            $Report = [PaCustomReport]::new($entry.name)
            $ReturnObject += $Report

            # Get Node Name Properties
            $ShortDatabaseName = [HelperXml]::parseCandidateConfigXml($entry.type, $true)
            $Report.Database = $Report.TranslateDatabaseName($ShortDatabaseName, 'Friendly')
            Write-Verbose "$VerbosePrefix getting report: Name $($entry.name), Database $($Report.Database)"

            # Add other properties to report
            $Report.Columns = [HelperXml]::parseCandidateConfigXml($entry.type.$ShortDatabaseName.'aggregate-by'.member, $false)
            $Report.Columns += [HelperXml]::parseCandidateConfigXml($entry.type.$ShortDatabaseName.values.member, $false)
            $Report.SortBy = [HelperXml]::parseCandidateConfigXml($entry.type.$ShortDatabaseName.sortby, $false)
            $Report.TimeFrame = [HelperXml]::parseCandidateConfigXml($entry.period, $false)
            $Report.EntriesShown = [HelperXml]::parseCandidateConfigXml($entry.topn, $false)
            $Report.Groups = [HelperXml]::parseCandidateConfigXml($entry.topm, $false)
            $Report.Description = [HelperXml]::parseCandidateConfigXml($entry.description, $false)
            $Report.Query = [HelperXml]::parseCandidateConfigXml($entry.query, $false)
        }

        $ReturnObject
    }
}