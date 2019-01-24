function Get-PaReportJob {
    [CmdletBinding(DefaultParameterSetName = 'singlejob')]
    Param (
        [Parameter(ParameterSetName = "alljobs", Mandatory = $False, Position = 0)]
        [Parameter(ParameterSetName = "singlejob", Mandatory = $True, Position = 0)]
        [int]$JobId,

        [Parameter(ParameterSetName = "singlejob", Mandatory = $False)]
        [switch]$Wait,

        [Parameter(ParameterSetName = "singlejob", Mandatory = $False)]
        [switch]$ShowProgress
    )

    BEGIN {
        $VerbosePrefix = "Get-PaReportJob:"
    }

    PROCESS {
        $Query = $global:PaDeviceObject.invokeReportGetQuery($JobId)
        $Result = $Query.response.result

        $JobId = $Result.job.Id
        $Job = [PaJob]::new($Result.job.id)
        $ReturnObject += $Job

        $Job.Enqueued = Get-Date $Result.job.tenq
        $Job.Dequeued = Get-Date $Result.job.tdeq
        $Job.Type = $Result.job.type
        $Job.Status = $Result.job.status
        $Job.Result = $Result.job.result
        $Job.Warnings = $Result.job.warnings.line -join "`r`n"
        $Job.Details = $Result.job.details.line -join "`r`n"
        $Job.Description = $Result.job.description
        $Job.User = $Result.job.user
        $Job.Progress = $Result.job.percent

        Write-Verbose "JobId $($Job.Id): Current Progress: $($Job.Progress)"
        $global:job = $job

        if ($ShowProgress -or $Wait) {
            if (($Job.Progress -eq 100) -or ($Job.Status -eq 'FIN')) {
                Write-Verbose "Job Done!"
            } else {
                $SleepTime = 10
                do {
                    Write-Verbose "Job Not Done! Waiting $SleepTime seconds"
                    Start-Sleep -Seconds $SleepTime
                    $Job = Get-PaReportJob -JobId $Job.Id -Wait
                    $global:job = $Job
                } while ((($Job | Get-Member -Name Status) -ne $null) -and ($Job.Status -ne 'FIN') -and ($Job.Progress -ne 100))
            }
        }

        $global:PaDeviceObject.LastResult.response.result.report

        <#
            Write-Verbose "$VerbosePrefix Job not complete"

            # Wait 10 seconds and check again
            do {
                if ($ShowProgress) {
                    $ProgressParams = @{}
                    $ProgressParams.Activity = "Checking Report Job Status..."
                    $ProgressParams.CurrentOperation = "Waiting to Contact Device..."
                    $ProgressParams.SecondsRemaining = 10
                    $ProgressParams.PercentComplete = $Job.Progress
                    $ProgressParams.Status = "$($Job.Progress) %"
                    Write-Progress @ProgressParams
                    for ($i = 1;$i -le 10; $i++) {
                        Start-Sleep -Seconds 1
                        $ProgressParams.SecondsRemaining = 10 - $i
                        Write-Progress @ProgressParams
                    }
                    $ProgressParams.CurrentOperation = "Contacting Device..."
                    Write-Progress @ProgressParams
                } else {
                    Start-Sleep -Seconds 10
                }
                Write-Verbose "$VerbosePrefix Checking again $($JobId)"
                $Job = Get-PaReportJob -JobId $JobId
                if ($ShowProgress) {
                    $ProgressParams.PercentComplete = $Job.Progress
                    $ProgressParams.Status = "$($Job.Progress) %"
                    Write-Progress @ProgressParams
                }
                Write-Verbose "$VerbosePrefix Progress: $($Job.Progress)"
            } while ($Job.Status -ne 'FIN')

            $ReturnObject = $Job#>

    }
}