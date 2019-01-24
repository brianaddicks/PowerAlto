function Set-PaCustomReport {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory = $False)]
        [string]$Description,

        [Parameter(Mandatory = $False)]
        [string]$Vsys,

        [Parameter(ParameterSetName = "summary", Mandatory = $True)]
        [ValidateSet('Application Statistics', 'Traffic', 'Threat', 'URL', 'Tunnel')]
        [string]$SummaryDatabase,

        [Parameter(ParameterSetName = "detailed", Mandatory = $True)]
        [ValidateSet('Traffic', 'Threat', 'URL', 'WildFire Submissions', 'Data Filtering', 'HIP Match', 'User-ID', 'Tunnel', 'Authentication')]
        [string]$DetailedLog,

        [Parameter(Mandatory = $True)]
        [string]$TimeFrame,

        [Parameter(Mandatory = $False)]
        [ValidateSet(5, 10, 25, 50, 100, 250, 500, 1000, 5000, 10000)]
        [int]$EntriesShown = 10,

        [Parameter(Mandatory = $False)]
        [ValidateSet(5, 10, 25, 50)]
        [int]$Groups = 10,

        [Parameter(Mandatory = $True)]
        [string[]]$Columns,

        [Parameter(Mandatory = $False)]
        [string]$Query,

        [Parameter(Mandatory = $False)]
        [string]$SortBy

    )

    BEGIN {
        $Xpath = $Global:PaDeviceObject.createXPath('reports', $Name)
    }

    PROCESS {

        $ConfigObject = [PaCustomReport]::new($Name)

        # Set the appropriate database name
        switch ($PsCmdlet.ParameterSetName) {
            'summary' {
                Write-Verbose "SummaryDatabase: $SummaryDatabase Summary"
                $ConfigObject.Database = "$SummaryDatabase Summary"
                continue
            }
            'detailed' {
                Write-Verbose "DetailedLog: $DetailedLog Detailed"
                $ConfigObject.Database = "$DetailedLog Detailed"
                continue
            }
        }

        # Common Properties
        $ConfigObject.TimeFrame = $TimeFrame
        $ConfigObject.EntriesShown = $EntriesShown
        $ConfigObject.Groups = $Groups
        $ConfigObject.Columns = $Columns
        $ConfigObject.Description = $Description
        $ConfigObject.Query = $Query
        $ConfigObject.SortBy = $SortBy

        $ElementXml = $ConfigObject.ToXml().reports.entry.InnerXml

        if ($PSCmdlet.ShouldProcess("Creating new report: $($ConfigObject.Name)")) {
            $Set = Invoke-PaApiConfig -Set -Xpath $XPath -Element $ElementXml

            $Set
        }
    }
}