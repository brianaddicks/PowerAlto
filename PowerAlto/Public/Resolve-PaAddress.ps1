function Resolve-PaAddress {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Name,

        [Parameter(Mandatory = $False, Position = 1)]
        [PaAddress[]]$Addresses = (Get-PaAddress),

        [Parameter(Mandatory = $False, Position = 2)]
        [PaAddressGroup[]]$AddressGroups = (Get-PaAddressGroup)
    )

    Begin {
        $VerbosePrefix = "Resolve-PaAddress:"
        $ReturnObject = @()

        $ReturnSameValue = @(
            'any'
        )
    }

    Process {
        Write-Verbose "$VerbosePrefix $Name"
        $GroupLookup = $AddressGroups | Where-Object { $_.Name -eq $Name }
        Write-Verbose "$VerbosePrefix $($GroupLookup.Count)"
        $AddressLookup = $Addresses | Where-Object { $_.Name -eq $Name }
        Write-Verbose "$VerbosePrefix $($AddressLookup.Count)"

        if ($GroupLookup) {
            $ReturnObject += $GroupLookup.Member | Resolve-PaAddress -Addresses $Addresses -AddressGroups $AddressGroups
        } elseif ($AddressLookup) {
            $ReturnObject += $AddressLookup.Value
        } elseif ($ReturnSameValue -contains $Name) {
            $ReturnObject += $Name
        } elseif ([HelperRegex]::isFqdnOrIpv4($Name, $true)) {
            $ReturnObject += $Name
        } else {
            Throw "$VerbosePrefix Could not find address: $Name"
        }
    }

    End {
        $ReturnObject
    }
}