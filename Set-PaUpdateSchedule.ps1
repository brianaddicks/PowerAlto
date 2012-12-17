function Set-PaUpdateSchedule {
    <#
	.SYNOPSIS
		Watch a given Jobs progress
	.DESCRIPTION
		
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

        [Parameter(Mandatory=$True)]
        [alias('c')]
        [ValidateSet("threats","av","url","all")] 
        [String]$Content,

        [Parameter(Mandatory=$False)]
        [alias('a')]
        [ValidateSet("download","install")] 
        [String]$Action,
        
        [Parameter(Mandatory=$True)]
        [alias('r')]
        [ValidateSet("daily","weekly","hourly","none")] 
        [String]$Recurrence,
        
        [Parameter(Mandatory=$False)]
        [alias('t')]
        [ValidatePattern("\d+\:\d+|\d{1,2}")]
        [String]$Time,

        [Parameter(Mandatory=$False)]
        [alias('d')]
        [ValidateSet("sunday","monday","tuesday","wednesday","thursday","friday","saturday")] 
        [String]$Day,

        [Parameter(Mandatory=$False)]
        [alias('th')]
        [ValidatePattern("\d+|none")]
        [String]$Threshold,

        [Parameter(Mandatory=$False)]
        [alias('p')]
        [Switch]$PeerSync
    )

    BEGIN {
        Function Set-Schedule ( [String]$Content) {
            $basexpath = "/config/devices/entry/deviceconfig/system/update-schedule/$Content/recurring"
            if ($Recurrence -eq "none") {
                $RecurrenceResponse = Send-PaApiQuery -Config delete -XPath $basexpath
                if ($RecurrenceResponse.response.status -eq "error") { throw $RecurrenceResponse.response.msg.line }
                return
            }
            switch ($Action) {
                download { $Action = "download-only" }
                install  { $Action = "download-and-install" }
            }
            if ($PeerSync) {
                $PeerSyncResponse = Send-PaApiQuery -Config set -xpath "$basexpath&element=<sync-to-peer>yes</sync-to-peer>"
                if ($PeerSyncResponse.response.status -eq "error") { throw $PeerSyncResponse.response.msg.line }
            }
            if ($Threshold -and ($Content -ne "url-database")) {
                if ($Threshold -eq "none") {
                    $ThresholdResponse = Send-PaApiQuery -Config delete -xpath "$basexpath/threshold"
                } else {
                    $ThresholdResponse = Send-PaApiQuery -Config set -XPath "$basexpath&element=<threshold>$Threshold</threshold>"
                }
                if ($ThresholdResponse.response.status -eq "error") { throw $ThresholdResponse.response.msg.line }
            }
            $ActionReponse = Send-PaApiQuery -Config set -XPath "$basexpath&element=<$Recurrence><action>$Action</action></$Recurrence>"
            if ($ActionResponse.response.status -eq "error") { throw $ActionResponse.response.msg.line }
            $TimeResponse = Send-PaApiQuery -Config set -XPath "$basexpath/$Recurrence&element=<at>$Time</at>"
            if ($TimeResponse.response.status -eq "error") { throw "$Recurrence";$TimeResponse.response.msg.line.line."#cdata-section" }
            if ($Recurrence -eq "weekly") {
                $DayResponse = Send-PaApiQuery -Config set -XPath "$basexpath/$Recurrence&element=<day-of-week>$Day</day-of-week>"
                if ($DayResponse.response.status -eq "error") { throw $DayResponse.response.msg.line }
            }
        }

        Function Process-Query ( [String]$PaConnectionString ) {
            switch ($Content) {
                threats { $Content = "threats"; Set-Schedule $Content      }
                av      { $Content = "anti-virus"; Set-Schedule $Content   }
                url     { $Content = "url-database"; Set-Schedule $Content }
                all     {
                            $Contents = @("threats","anti-virus","url-database")
                            foreach ($C in $Contents) {
                                Set-Schedule $C
                            }
                        }
            }
        }
    }

    PROCESS {
        if (($Recurrence -eq "Hourly") -and ($Content -ne "av")) { Throw "Only Threats can be scheduled hourly" }
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