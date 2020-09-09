function Test-PaVpn {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$TunnelName,

        [Parameter(Mandatory = $False)]
        [switch]$ExcludeIke,

        [Parameter(Mandatory = $False)]
        [switch]$ExcludeIpsec,

        [Parameter(Mandatory = $False)]
        [string[]]$ProxyId
    )

    BEGIN {
        $VerbosePrefix = "Test-PaVpn:"
        $CMD = "<test><vpn><ike-sa><gateway>$TunnelName</gateway></ike-sa></vpn></test>"
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