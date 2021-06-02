function New-PaHaSetup {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = "activeactive")]
        [Parameter(Mandatory = $false, ParameterSetName = "activepassive")]
        [switch]$Enabled,

        [Parameter(Mandatory = $true, ParameterSetName = "activeactive")]
        [Parameter(Mandatory = $false, ParameterSetName = "activepassive")]
        [int]$GroupId,

        [Parameter(Mandatory = $false, ParameterSetName = "activeactive")]
        [Parameter(Mandatory = $false, ParameterSetName = "activepassive")]
        [string]$Description,

        [Parameter(Mandatory = $false, ParameterSetName = "activeactive")]
        [Parameter(Mandatory = $false, ParameterSetName = "activepassive")]
        [switch]$EnableConfigSync,

        [Parameter(Mandatory = $true, ParameterSetName = "activeactive")]
        [Parameter(Mandatory = $false, ParameterSetName = "activepassive")]
        [string]$PeerHa1IpAddress,

        [Parameter(Mandatory = $false, ParameterSetName = "activeactive")]
        [Parameter(Mandatory = $false, ParameterSetName = "activepassive")]
        [string]$BackupPeerHa1IpAddress,

        # ActiveActive
        [Parameter(Mandatory = $true, ParameterSetName = "activeactive")]
        [switch]$ActiveActive,

        [Parameter(Mandatory = $true, ParameterSetName = "activeactive")]
        [int]$DeviceId
    )

    Begin {
        $VerbosePrefix = "New-PaHaSetup:"
    }

    Process {
    }

    End {
        $ConfigObject = [PaHaSetup]::new()
        $ConfigObject.Enabled = $Enabled
        $ConfigObject.GroupId = $GroupId
        $ConfigObject.Description = $Description
        $ConfigObject.EnableConfigSync = $EnableConfigSync
        $ConfigObject.PeerHa1IpAddress = $PeerHa1IpAddress
        $ConfigObject.BackupPeerHa1IpAddress = $BackupPeerHa1IpAddress

        # ActiveActive
        if ($ActiveActive) {
            $ConfigObject.Mode = 'ActiveActive'
            $ConfigObject.DeviceId = $DeviceId
        }

        $ConfigObject
    }
}