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
        [string]$TranslatedDestinationAddress,

        [Parameter(Mandatory = $False)]
        [int]$TranslatedDestinationPort
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

        # TranslatedDestinationAddress
        if ($SourceTranslationType) {
            $ReturnObject.TranslatedDestinationAddress = $TranslatedDestinationAddress
        }

        # TranslatedDestinationPort
        if ($TranslatedDestinationPort) {
            $ReturnObject.TranslatedDestinationPort = $TranslatedDestinationPort
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