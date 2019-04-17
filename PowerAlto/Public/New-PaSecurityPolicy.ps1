function New-PaSecurityPolicy {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ParameterSetName = "name", Mandatory = $True, Position = 0)]
        [string]$Name
    )

    Begin {
        $VerbosePrefix = "New-PaSecurityPolicy:"
    }

    Process {
    }

    End {
        [PaSecurityPolicy]::new($Name)
    }
}