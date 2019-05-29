function Set-PaPanoramaConfig {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = "noclass")]
        [string]$PrimaryServer,

        [Parameter(Mandatory = $false, ParameterSetName = "noclass")]
        [string]$SecondaryServer,

        [Parameter(Mandatory = $false, ParameterSetName = "noclass")]
        [int]$ReceiveTimeout = 240,

        [Parameter(Mandatory = $false, ParameterSetName = "noclass")]
        [int]$SendTimeout = 240,

        [Parameter(Mandatory = $false, ParameterSetName = "noclass")]
        [int]$RetryCount = 25,

        [Parameter(Mandatory = $false, ParameterSetName = "noclass")]
        [switch]$DisableDeviceMonitoring,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "class")]
        [PaPanoramaConfig]$PaPanoramaConfig
    )

    Begin {
        $VerbosePrefix = "New-PaPanoramaConfig:"
    }

    Process {
        $ConfigObject = $PaPanoramaConfig
    }

    End {
        switch ($PsCmdlet.ParameterSetName) {
            'noclass' {
                # Setup New Item
                $Params = @{
                    PrimaryServer           = $PrimaryServer
                    SecondaryServer         = $SecondaryServer
                    ReceiveTimeout          = $ReceiveTimeout
                    SendTimeout             = $SendTimeout
                    RetryCount              = $RetryCount
                    DisableDeviceMonitoring = $DisableDeviceMonitoring
                }
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