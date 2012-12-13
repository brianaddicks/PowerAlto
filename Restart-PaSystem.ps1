function Restart-PaSystem {
    <#
	.SYNOPSIS
		Returns Security Ruleset from Palo Alto firewall.
	.DESCRIPTION
		Returns Security Ruleset from Palo Alto firewall.
	.EXAMPLE
        EXAMPLES!
	.EXAMPLE
		EXAMPLES!
	.PARAMETER PaConnectionString
		Specificies the Palo Alto connection string with address and apikey.
	#>

    Param (
        [Parameter(Mandatory=$False)]
        [alias('pc')]
        [String]$PaConnection,

        [Parameter(Mandatory=$False)]
        [alias('dw')]
        [String]$DontWait
    )

    BEGIN {
        Function Process-Query ( [String]$PaConnectionString ) {
            $xpath = "<request><restart><system></system></restart></request>"
            $Reboot = Send-PaApiQuery -Op $xpath
            if ($DontWait) { return $Reboot }
            
            sleep 15
            $RebootTest = $false
            while (!($RebootTest)) {
                try {
                    Write-Host -NoNewline "Trying"
                    $RebootJob = Watch-PaJob -job 1 -c "Waiting for reboot"
                    if ($RebootJob.response) { $RebootTest = $true }
                } catch {
                    Write-Host -NoNewline ", Waiting 15 seconds"
                    for ($w = 0;$w -le 13;$w++) {
                        Write-Host -NoNewline "."
                        sleep 1
                    }
                    Write-Host "."
                    $RebootTest = $false
                }
                
            }
            return $RebootJob
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