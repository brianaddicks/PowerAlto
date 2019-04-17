function Resolve-PaSecurityPolicy {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [PaSecurityPolicy]$PaSecurityPolicy,

        [Parameter(Mandatory = $False, Position = 1)]
        [PaAddress[]]$Addresses = (Get-PaAddress),

        [Parameter(Mandatory = $False, Position = 2)]
        [PaAddressGroup[]]$AddressGroups = (Get-PaAddressGroup)
    )

    Begin {
        $VerbosePrefix = "Resolve-PaSecurityPolicy:"
        $ReturnObject = @()
    }

    Process {
        # Source resolution
        $Field = 'SourceAddress'
        $ResolvedField = Resolve-PaAddress -Name $PaSecurityPolicy -Addresses $Addresses -AddressGroups $AddressGroups
        foreach ($r in $ResolvedField) {

        }
    }

    End {
        $ReturnObject
    }
}