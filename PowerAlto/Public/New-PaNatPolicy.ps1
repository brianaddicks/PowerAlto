function New-PaNatPolicy {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory = $False)]
        [string]$Description,

        [Parameter(Mandatory = $False)]
        [ValidateSet('ipv4', 'nat64', 'nptv6')]
        [string]$NatType = 'ipv4',

        [Parameter(Mandatory = $False)]
        [string[]]$Tag,

        [Parameter(Mandatory = $true)]
        [string[]]$SourceZone,

        [Parameter(Mandatory = $true)]
        [string]$DestinationZone,

        [Parameter(Mandatory = $False)]
        [string]$DestinationInterface = 'any',

        [Parameter(Mandatory = $False)]
        [string]$Service = 'any',

        [Parameter(Mandatory = $False)]
        [string[]]$SourceAddress = 'any',

        [Parameter(Mandatory = $False)]
        [string[]]$DestinationAddress = 'any',

        [Parameter(Mandatory = $False)]
        [ValidateSet('dynamic-ip', 'dynamic-ip-and-port', 'static-ip', 'none')]
        [string]$SourceTranslationType = 'none',

        [Parameter(Mandatory = $False)]
        [string]$SourceTranslatedAddress,

        [Parameter(Mandatory = $False)]
        [bool]$BiDirectional,

        [Parameter(Mandatory = $False)]
        [ValidateSet('dynamic-ip', 'static-ip', 'none')]
        [string]$DestinationTranslationType,

        [Parameter(Mandatory = $False)]
        [string]$DestinationTranslatedAddress,

        [Parameter(Mandatory = $False)]
        [ValidateRange(1, 65535)]
        [int]$DestinationTranslatedPort,

        [Parameter(Mandatory = $False)]
        [bool]
        $DnsRewrite,

        [Parameter(Mandatory = $False)]
        [ValidateSet('reverse', 'forward')]
        [string]$DnsRewriteDirection = 'reverse',

        [Parameter(Mandatory = $False)]
        [ValidateSet('primary', 'both', "0", "1")]
        [string]$ActiveActiveDeviceBinding
    )

    Begin {
        $VerbosePrefix = "New-PaNatPolicy:"
        $ReturnObject = [PaNatPolicy]::new($Name)

        # Description
        if ($Description) {
            $ReturnObject.Description = $Description
        }

        # Tag
        if ($Tag) {
            $ReturnObject.Tags = $Tag
        }

        # SourceTranslationType
        if ($SourceTranslationType) {
            $ReturnObject.SourceTranslationType = $SourceTranslationType
        }

        # SourceTranslatedAddress
        if ($SourceTranslatedAddress) {
            $ReturnObject.SourceTranslatedAddress = $SourceTranslatedAddress
        }

        # BiDirectional
        if ($BiDirectional) {
            $ReturnObject.BiDirectional = $BiDirectional
        }

        # DestinationTranslationType
        if ($DestinationTranslationType) {
            $ReturnObject.$DestinationTranslationType = $DestinationTranslationType
        }

        # DestinationTranslatedAddress
        if ($DestinationTranslatedAddress) {
            $ReturnObject.DestinationTranslatedAddress = $DestinationTranslatedAddress
        }

        # DestinationTranslatedPort
        if ($DestinationTranslatedPort) {
            $ReturnObject.DestinationTranslatedPort = $DestinationTranslatedPort
        }

        # DnsRewrite
        if ($DnsRewrite) {
            $ReturnObject.DnsRewrite = $DnsRewrite
            if ($DnsRewriteDirection) {
                $ReturnObject.DnsRewriteDirection = $DnsRewriteDirection
            }
        }

        # ActiveActiveDeviceBinding
        if ($ActiveActiveDeviceBinding) {
            $ReturnObject.ActiveActiveDeviceBinding = $ActiveActiveDeviceBinding
        }

        # Mandatory Properties
        $ReturnObject.NatType = $NatType
        $ReturnObject.SourceZone = $SourceZone
        $ReturnObject.DestinationZone = $DestinationZone
        $ReturnObject.DestinationInterface = $DestinationInterface
        $ReturnObject.Service = $Service
        $ReturnObject.SourceAddress = $SourceAddress
        $ReturnObject.DestinationAddress = $DestinationAddress
    }

    Process {
    }

    End {
        $ReturnObject
    }
}