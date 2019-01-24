function Get-PaJob {
    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName = "alljobs", Mandatory = $False, Position = 0)]
        [Parameter(ParameterSetName = "singlejob", Mandatory = $True, Position = 0)]
        [int]$JobId,

        [Parameter(ParameterSetName = "latest", Mandatory = $True, Position = 0)]
        [switch]$Latest,

        [Parameter(ParameterSetName = "singlejob", Mandatory = $False)]
        [Parameter(ParameterSetName = "latest", Mandatory = $False)]
        [switch]$Wait,

        [Parameter(ParameterSetName = "singlejob", Mandatory = $False)]
        [Parameter(ParameterSetName = "latest", Mandatory = $False)]
        [switch]$ShowProgress,

        [Parameter(ParameterSetName = "singlejob", Mandatory = $False)]
        [switch]$ReportJob
    )

    BEGIN {
        $VerbosePrefix = "Get-PaJob:"
        $Cmd = '<show><jobs>'
        if ($JobId) {
            $Cmd += '<id>' + $JobId + '</id>'
        } else {
            $Cmd += '<all/>'
        }
        $Cmd += '</jobs></show>'
    }

    PROCESS {
        if ($ReportJob) {
            $Query = $global:PaDeviceObject.invokeReportGetQuery($JobId)
        } else {
            $Query = Invoke-PaApiOperation -Cmd $Cmd
        }
        $Results = $Query.response.result.job

        if ($Latest) {
            $Results = $Results[0]
        }

        $ReturnObject = @()
        foreach ($result in $Results) {
            $JobId = $result.id
            $Job = [PaJob]::new($result.id)
            $ReturnObject += $Job

            $Job.Enqueued = Get-Date $result.tenq
            $Job.Dequeued = Get-Date $result.tdeq
            $Job.Type = $result.type
            $Job.Status = $result.status
            $Job.Result = $result.result
            $Job.Warnings = $result.warnings.line -join "`r`n"
            $Job.Details = $result.details.line -join "`r`n"
            $Job.Description = $result.description
            $Job.User = $result.user
            if ($ReportJob) {
                $Job.Progress = $result.percent
            } else {
                $Job.Progress = $result.progress
            }
            if (($Job.Status -eq 'FIN') -and (!($ReportJob))) {
                $Job.TimeComplete = Get-Date $result.tfin
            }
        }

        Write-Verbose "Current Progress: $($Job.Progress)"

        if (($Wait -or $ShowProgress) -and ($Job.Progress -ne 100) -and ($Job.Status -ne 'FIN')) {
            Write-Verbose "$VerbosePrefix Job not complete"

            # Wait 10 seconds and check again
            do {
                if ($ShowProgress) {
                    $ProgressParams = @{}
                    $ProgressParams.Activity = "Checking Commit Status..."
                    $ProgressParams.CurrentOperation = "Waiting to Contact Device..."
                    $ProgressParams.SecondsRemaining = 10
                    $ProgressParams.PercentComplete = $Job.Progress
                    $ProgressParams.Status = "$($Job.Progress) %"
                    Write-Progress @ProgressParams
                    for ($i = 1; $i -le 10; $i++) {
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
                if ($ReportJob) {
                    $Job = Get-PaJob -JobId $JobId -ReportJob
                } else {
                    $Job = Get-PaJob -JobId $JobId
                }
                if ($ShowProgress) {
                    $ProgressParams.PercentComplete = $Job.Progress
                    $ProgressParams.Status = "$($Job.Progress) %"
                    Write-Progress @ProgressParams
                }
                Write-Verbose "$VerbosePrefix Progress: $($Job.Progress)"

                if (!($Job.Status) -and $ReportJob) {
                    break
                }

            } while ($Job.Status -ne 'FIN')

            $ReturnObject = $Job
        }
        if ($ReportJob) {
            $Global:PaDeviceObject.LastResult.response.result.report.entry
        } else {
            $ReturnObject
        }
    }
}