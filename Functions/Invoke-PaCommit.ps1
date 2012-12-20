function Invoke-PaCommit {
	<#
	.SYNOPSIS
		Commits candidate config to Palo Alto firewall
	.DESCRIPTION
		Commits candidate config to Palo Alto firewall and returns resulting job stats.
	.EXAMPLE
        Needs to write some examples
	.EXAMPLE
		Needs to write some examples
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
    .PARAMETER Force
		Forces the commit command in the event of a conflict.
	#>
    
    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection,

        [Parameter(Mandatory=$False)]
        [switch]$Force
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

        Function Process-Query ( [String]$PaConnectionString ) {
            if ($Force) {
                $CustomData = Send-PaApiQuery -commit -force
            } else {
                $CustomData = Send-PaApiQuery -commit
            }
            if ($CustomData.response.status -eq "success") {
                if ($CustomData.response.msg -match "no changes") {
                    Return "There are no changes to commit."
                }
                $job = $CustomData.response.result.job
                $cmd = "<show><jobs><id>$job</id></jobs></show>"
                $JobStatus = Send-PaApiQuery -op "$cmd"
                while ($JobStatus.response.result.job.status -ne "FIN") {
                    Write-Progress -Activity "Commiting to PA" -Status "$($JobStatus.response.result.job.progress)% complete"-PercentComplete ($JobStatus.response.result.job.progress)
                    $JobStatus = Send-PaApiQuery -op "$cmd"
                }
                return $JobStatus.response.result.job
            }
            Throw "$($CustomData.response.result.msg)"
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

