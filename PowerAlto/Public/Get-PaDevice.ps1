function Get-PaDevice {
    [CmdletBinding(DefaultParameterSetName = 'ApiKey')]
    Param (
        [Parameter(ParameterSetName = "ApiKey", Mandatory = $True, Position = 0)]
        [Parameter(ParameterSetName = "Credential", Mandatory = $True, Position = 0)]
        [ValidatePattern("\d+\.\d+\.\d+\.\d+|(\w\.)+\w")]
        [string]$DeviceAddress,

        [Parameter(ParameterSetName = "ApiKey", Mandatory = $True, Position = 1)]
        [string]$ApiKey,

        [Parameter(ParameterSetName = "Credential", Mandatory = $True, Position = 1)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(ParameterSetName = "ApiKey", Mandatory = $False, Position = 2)]
        [Parameter(ParameterSetName = "Credential", Mandatory = $False, Position = 2)]
        [int]$Port = 443,

        [Parameter(ParameterSetName = "ApiKey", Mandatory = $False)]
        [Parameter(ParameterSetName = "Credential", Mandatory = $False)]
        [alias('http')]
        [switch]$HttpOnly,

        [Parameter(ParameterSetName = "ApiKey", Mandatory = $False)]
        [Parameter(ParameterSetName = "Credential", Mandatory = $False)]
        [switch]$SkipCertificateCheck,

        [Parameter(Mandatory = $False)]
        [alias('q')]
        [switch]$Quiet,

        [Parameter(Mandatory = $False)]
        [string]$Vsys,

        [Parameter(ParameterSetName = "offline", Mandatory = $True, Position = 0)]
        [string]$ConfigFile
    )

    BEGIN {
        $VerbosePrefix = "Get-PaDevice:"

        if ($HttpOnly) {
            $Protocol = "http"
            if (!$Port) { $Port = 80 }
        } else {
            $Protocol = "https"
            if (!$Port) { $Port = 443 }
        }
    }

    PROCESS {

        if ($ApiKey) {
            Write-Verbose "$VerbosePrefix API Key supplied"
            $global:PaDeviceObject = [PaloAltoDevice]::new($DeviceAddress, $ApiKey)
        } else {
            Write-Verbose "$VerbosePrefix Attempting to generate API Key."
            $global:PaDeviceObject = [PaloAltoDevice]::new($DeviceAddress, $Credential)
            Write-Verbose "$VerbosePrefix API Key successfully generated."
        }

        # Test API connection
        # When generating an api key, the connection is already tested.
        # This grabs serial/version info from the box and tests if you're just
        # supplying an api key yourself.
        Write-Verbose "$VerbosePrefix Attempting to test connection"
        $TestConnect = $global:PaDeviceObject.testConnection()
        if ($TestConnect) {
            if ($Vsys) {
                $global:PaDeviceObject.Vsys = $Vsys
            }
            if (!($Quiet)) {
                return $global:PaDeviceObject
            }
        } else {
            Throw "$VerbosePrefix testConnection() failed."
        }
    }
}