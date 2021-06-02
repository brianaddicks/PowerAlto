function Resolve-PaService {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Name,

        [Parameter(Mandatory = $False, Position = 1)]
        [PaService[]]$Services = (Get-PaService),

        [Parameter(Mandatory = $False, Position = 2)]
        [PaServiceGroup[]]$ServiceGroups = (Get-PaServiceGroup)
    )

    Begin {
        $VerbosePrefix = "Resolve-PaService:"
        $ReturnObject = @()

        $ReturnSameValue = @(
            'any'
            'application-default'
        )
    }

    Process {
        Write-Verbose "$VerbosePrefix $Name"
        $GroupLookup = $ServiceGroups | Where-Object { $_.Name -eq $Name }
        Write-Verbose "$VerbosePrefix $($GroupLookup.Count)"
        $ServiceLookup = $Services | Where-Object { $_.Name -eq $Name }
        Write-Verbose "$VerbosePrefix $($ServiceLookup.Count)"

        if ($GroupLookup) {
            $ReturnObject += $GroupLookup.Member | Resolve-PaService -Services $Services -ServiceGroups $ServiceGroups
        } elseif ($ServiceLookup) {
            $ReturnObject += $ServiceLookup.Protocol + '/' + $ServiceLookup.DestinationPort
        } elseif ($ReturnSameValue -contains $Name) {
            $ReturnObject += $Name
        } else {
            Throw "$VerbosePrefix Could not find service: $Name"
        }
    }

    End {
        $ReturnObject
    }
}