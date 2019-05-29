function Resolve-PaField {
    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName = "PaSecurityPolicyAddress", Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = "PaSecurityPolicyService", Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [PaSecurityPolicy]
        $PaSecurityPolicy,

        [Parameter(ParameterSetName = "PaNatPolicyAddress", Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = "PaNatPolicyService", Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [PaNatPolicy]
        $PaNatPolicy,

        [Parameter(ParameterSetName = "PaNatPolicyAddress", Mandatory = $true, Position = 1)]
        [Parameter(ParameterSetName = "PaSecurityPolicyAddress", Mandatory = $true, Position = 1)]
        [PaAddress[]]$Addresses,

        [Parameter(ParameterSetName = "PaNatPolicyAddress", Mandatory = $true, Position = 2)]
        [Parameter(ParameterSetName = "PaSecurityPolicyAddress", Mandatory = $true, Position = 2)]
        [PaAddressGroup[]]$AddressGroups,

        [Parameter(ParameterSetName = "PaNatPolicyService", Mandatory = $False, Position = 3)]
        [Parameter(ParameterSetName = "PaSecurityPolicyService", Mandatory = $False, Position = 3)]
        [PaService[]]$Services,

        [Parameter(ParameterSetName = "PaNatPolicyService", Mandatory = $False, Position = 4)]
        [Parameter(ParameterSetName = "PaSecurityPolicyService", Mandatory = $False, Position = 4)]
        [PaServiceGroup[]]$ServiceGroups,

        [Parameter(Mandatory = $true)]
        [string]$FieldName
    )

    Begin {
        $VerbosePrefix = "Resolve-PaField:"
        $ReturnObject = @()
    }

    Process {
        if ($SecurityPolicy) {
            $PaPolicy = $SecurityPolicy
        } elseif ($NatPolicy) {
            $PaPolicy = $NatPolicy
        }

        # Source resolution
        switch -Regex ($FieldName) {
            '.*Address' {
                $ResolvedField = $PaPolicy.$FieldName | Resolve-PaAddress -Addresses $Addresses -AddressGroups $AddressGroups
            }
            'Service' {
                $ResolvedField = $PaPolicy.$FieldName | Resolve-PaService -Services $Services -ServiceGroups $ServiceGroups
            }
        }

        foreach ($r in $ResolvedField) {
            $NewPolicy = $PaPolicy.Clone()
            $ReturnObject += $NewPolicy
            $NewPolicy.$FieldName = $r
        }
    }

    End {
        $ReturnObject
    }
}