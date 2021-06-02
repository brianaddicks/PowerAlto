function Resolve-PaSecurityPolicy {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [PaSecurityPolicy]$PaSecurityPolicy,

        [Parameter(Mandatory = $False, Position = 1)]
        [PaAddress[]]$Addresses = (Get-PaAddress),

        [Parameter(Mandatory = $False, Position = 2)]
        [PaAddressGroup[]]$AddressGroups = (Get-PaAddressGroup),

        [Parameter(Mandatory = $False, Position = 3)]
        [PaService[]]$Services = (Get-PaService),

        [Parameter(Mandatory = $False, Position = 4)]
        [PaServiceGroup[]]$ServiceGroups = (Get-PaServiceGroup)
    )

    Begin {
        $VerbosePrefix = "Resolve-PaSecurityPolicy:"
        $ReturnObject = @()
    }

    Process {
        # Addresses
        $ResolvedPolicy = $PaSecurityPolicy | Resolve-PaField -Addresses $Addresses -AddressGroups $AddressGroups -FieldName SourceAddress
        $ResolvedPolicy = $ResolvedPolicy | Resolve-PaField -Addresses $Addresses -AddressGroups $AddressGroups -FieldName DestinationAddress

        # Service
        $ResolvedPolicy = $ResolvedPolicy | Resolve-PaField -Services $Services -ServiceGroups $ServiceGroups -FieldName Service
        $ReturnObject += $ResolvedPolicy
    }

    End {
        $ReturnObject
    }
}