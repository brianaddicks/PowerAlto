function New-PaLogJob {
	<#
	.SYNOPSIS
		Formulate and send an api query to a PA firewall.
	.DESCRIPTION
		Formulate and send an api query to a PA firewall.
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$True)]
        [ValidateSet("traffic","threat","config","system","hip-match")]
        [String]$Type,

        [Parameter(Mandatory=$True)]
        [alias('q')]
        [String]$Query,

        [Parameter(Mandatory=$False)]
        [alias('nl')]
        [ValidateRange(1,5000)]
        [Decimal]$NumberLogs,

        [Parameter(Mandatory=$False)]
        [alias('s')]
        [String]$Skip,

        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection
    )

    BEGIN {
        Add-Type -AssemblyName System.Web
        $WebClient = New-Object System.Net.WebClient

        Function Process-Query ( [String]$PaConnectionString ) {
            $url = $PaConnectionString

            $url += "&type=log"
            $url += "&log-type=$Type"

            if ($Query)      { $Query  = [System.Web.HttpUtility]::UrlEncode($Query)
                               $url   += "&query=$Query" }
            if ($NumberLogs) { $url += "&nlogs=$NumberLogs" }
            if ($Skip)       { $url += "&skip=$SkipLogs" }

            $global:lasturl  = $url
            $global:response = [xml]$WebClient.DownloadString($url)
            if ($global:response.response.status -ne "success") {
                Throw $global:response.response.result.msg
            }

            return $global:response
        }
    }

    PROCESS {
        if ($PaConnection) {
            Process-Query $PaConnection
        } else {
            if (Test-PaConnection) {
                foreach ($Connection in $Global:PaConnectionArray) {
                    Process-Query $Connection.ConnectionString
                }
            } else {
                Throw "No Connections"
            }
        }
    }
}