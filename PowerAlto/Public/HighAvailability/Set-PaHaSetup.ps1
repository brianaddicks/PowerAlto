function Set-PaHaSetup {
    [CmdletBinding(SupportsShouldProcess = $True)]
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
        [int]$DeviceId,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "class")]
        [PaHaSetup]$PaHaSetup
    )

    Begin {
        $VerbosePrefix = "New-PaHaSetup:"
    }

    Process {
        $ConfigObject = $PaPanoramaConfig
    }

    End {
        switch ($PsCmdlet.ParameterSetName) {
            'noclass' {
                # Setup New Item
                $Params = @{
                    Enabled                = $Enabled
                    GroupId                = $GroupId
                    Description            = $Description
                    EnableConfigSync       = $EnableConfigSync
                    PeerHa1IpAddress       = $PeerHa1IpAddress
                    BackupPeerHa1IpAddress = $BackupPeerHa1IpAddress
                }

                # ActiveActive
                [Parameter(Mandatory = $true, ParameterSetName = "activeactive")]
                [switch]$ActiveActive,

                [Parameter(Mandatory = $true, ParameterSetName = "activeactive")]
                [int]$DeviceId

                $ConfigObject = New-PaPanoramaConfig @Params
            }
        }

        $ShouldProcessMessage = "Adding Panorama Configuration to PaDevice $($global:PaDeviceObject.Name)`r`n"
        $ShouldProcessMessage += "PrimaryServer: $($ConfigObject.PrimaryServer)`r`n"
        $ShouldProcessMessage += "SecondaryServer: $($ConfigObject.SecondaryServer)`r`n"
        $ShouldProcessMessage += "ReceiveTimeout: $($ConfigObject.ReceiveTimeout)`r`n"
        $ShouldProcessMessage += "SendTimeout: $($ConfigObject.SendTimeout)`r`n"
        $ShouldProcessMessage += "RetryCount: $($ConfigObject.RetryCount)`r`n"
        $ShouldProcessMessage += "EnableDeviceMonitoring: $($ConfigObject.EnableDeviceMonitoring)`r`n"

        $XPathNode = $ConfigObject::XPathNode

        $ElementXml = $ConfigObject.ToXml().deviceconfig.InnerXml
        $Xpath = $Global:PaDeviceObject.createXPath($XPathNode, $null)
        $ShouldProcessMessage += "XPath: $XPath"

        if ($PSCmdlet.ShouldProcess($ShouldProcessMessage)) {
            $Set = Invoke-PaApiConfig -Set -Xpath $XPath -Element $ElementXml

            $Set
        }
    }
}