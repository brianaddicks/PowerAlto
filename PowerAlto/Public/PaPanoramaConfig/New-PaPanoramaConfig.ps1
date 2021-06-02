function New-PaPanoramaConfig {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [string]$PrimaryServer,

        [Parameter(Mandatory = $false)]
        [string]$SecondaryServer,

        [Parameter(Mandatory = $false)]
        [int]$ReceiveTimeout = 240,

        [Parameter(Mandatory = $false)]
        [int]$SendTimeout = 240,

        [Parameter(Mandatory = $false)]
        [int]$RetryCount = 25,

        [Parameter(Mandatory = $false)]
        [switch]$DisableDeviceMonitoring
    )

    Begin {
        $VerbosePrefix = "New-PaPanoramaConfig:"
    }

    Process {
    }

    End {
        $ConfigObject = [PaPanoramaConfig]::new()
        $ConfigObject.PrimaryServer = $PrimaryServer
        $ConfigObject.SecondaryServer = $SecondaryServer
        $ConfigObject.ReceiveTimeout = $ReceiveTimeout
        $ConfigObject.SendTimeout = $SendTimeout
        $ConfigObject.RetryCount = $RetryCount

        if ($DisableDeviceMonitoring) {
            $ConfigObject.EnableDeviceMonitoring = $false
        }

        $ConfigObject
    }
}