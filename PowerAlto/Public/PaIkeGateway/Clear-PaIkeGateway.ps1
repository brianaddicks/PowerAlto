function Clear-PaIkeGateway {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    BEGIN {
        $VerbosePrefix = "Clear-PaIkeGateway:"
    }

    PROCESS {
        $Cmd = "<clear><vpn><ike-sa><gateway>$Name</gateway></ike-sa></vpn></clear>"

        $CommandBeingRun = [regex]::split($Cmd, '[<>\/]+') | Select-Object -Unique | Where-Object { $_ -ne "" }
        if ($PSCmdlet.ShouldProcess("Running Operational Command: $CommandBeingRun")) {
            $Query = Invoke-PaApiOperation -Cmd $Cmd
            $Results = $Query.response.result
        }
    }

    END {
        $Results.member
    }
}
