function Invoke-PaCommit {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $False)]
        [switch]$Force,

        [Parameter(Mandatory = $False)]
        [switch]$Wait,

        [Parameter(Mandatory = $False)]
        [switch]$ShowProgress
    )

    BEGIN {
        $VerbosePrefix = "Invoke-PaCommit:"
        $Cmd = '<commit>'
        if ($Force) {
            $Cmd += '<force/>'
        }
        $Cmd += '</commit>'
    }

    PROCESS {
        $CommandBeingRun = [regex]::split($Cmd, '[<>\/]+') | Select-Object -Unique | Where-Object { $_ -ne "" }
        if ($PSCmdlet.ShouldProcess("Running Operational Command: $CommandBeingRun")) {
            $Response = $global:PaDeviceObject.invokeCommitQuery($Cmd)
            if ($Wait -or $ShowProgress) {
                Get-PaJob -JobId $Response.response.result.job -Wait:$Wait -ShowProgress:$ShowProgress
            }
        }
    }
}