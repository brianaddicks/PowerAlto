function Watch-PaJob {
    <#
	.SYNOPSIS
		Watch a given Jobs progress.
	.DESCRIPTION
		
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey. If ommitted, $global:PaConnectionArray will be used
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection,

        [Parameter(Mandatory=$True)]
        [alias('j')]
        [Decimal]$Job,

        [Parameter(Mandatory=$False)]
        [alias('s')]
        [Decimal]$Size,
        
        [Parameter(Mandatory=$False)]
        [alias('i')]
        [Decimal]$Id,
        
        [Parameter(Mandatory=$False)]
        [alias('p')]
        [Decimal]$Parentid,

        [Parameter(Mandatory=$True)]
        [alias('c')]
        [String]$Caption
    )

    BEGIN {
        Function Process-Query ( [String]$PaConnectionString ) {
            $cmd = "<show><jobs><id>$Job</id></jobs></show>"
            $JobStatus = Send-PaApiQuery -op "$cmd"
            $TimerStart = Get-Date
            
            $ProgressParams = @{}
            $ProgressParams.add("Activity",$Caption)
            if ($Id)       { $ProgressParams.add("Id",$Id) }
            if ($ParentId) { $ProgressParams.add("ParentId",$ParentId) }
            $ProgressParams.add("Status",$null)
            $ProgressParams.add("PercentComplete",$null)

            while ($JobStatus.response.result.job.status -ne "FIN") {
                $JobProgress = $JobStatus.response.result.job.progress
                $SizeComplete = ([decimal]$JobProgress * $Size)/100
                $Elapsed = ((Get-Date) - $TimerStart).TotalSeconds
                if ($Elapsed -gt 0) { $Speed = [math]::Truncate($SizeComplete/$Elapsed*1024) }
                $Status = $null
                if ($size)          { $Status = "$Speed`KB/s " } 
                $Status += "$($JobProgress)% complete"
                $ProgressParams.Set_Item("Status",$Status)
                $ProgressParams.Set_Item("PercentComplete",$JobProgress)
                Write-Progress @ProgressParams
                $JobStatus = Send-PaApiQuery -op "$cmd"
            }
            $ProgressParams.Set_Item("PercentComplete",100)
            Write-Progress @ProgressParams
            return $JobStatus
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