function New-PaNatPolicy {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ParameterSetName = "name", Mandatory = $True, Position = 0)]
        [string]$Name
    )

    Begin {
        $VerbosePrefix = "New-PaNatPolicy:"
    }

    Process {
    }

    End {
        [PaNatPolicy]::new($Name)
    }
}