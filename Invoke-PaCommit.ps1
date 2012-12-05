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
		Specificies the Palo Alto connection string with address and apikey.
    .PARAMETER Force
		Forces the commit command in the event of a conflict.
	#>
    
    Param (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$PaConnectionString,

        [Parameter(Position=1)]
        [switch]$Force
    )

    BEGIN {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        $type = "commit"
        $cmd = "<commit></commit>"
        if ($Force) {
            $cmd = "<commit><force></force></commit>"
        }   
    }

    PROCESS {
        $url = "$PaConnectionString&type=$type&cmd=$cmd"
        $CustomData = [xml]$WebClient.DownloadString($Url)
        if ($CustomData.response.status -eq "success") {
            if ($CustomData.response.msg -match "no changes") {
                Return "There are no changes to commit."
            }
            $job = $CustomData.response.result.job
            $cmd = "<show><jobs><id>$job</id></jobs></show>"
            $url = "$PaConnectionString&type=op&cmd=$cmd"
            $JobStatus = [xml]$WebClient.DownloadString($Url)
            while ($JobStatus.response.result.job.status -ne "FIN") {
                Write-Progress -Activity "Commiting to PA" -Status "$($JobStatus.response.result.job.progress)% complete"-PercentComplete ($JobStatus.response.result.job.progress)
                $JobStatus = [xml]$WebClient.DownloadString($Url)
            }
            return $JobStatus.response.result.job
        }
        return "Error"
    }
}

