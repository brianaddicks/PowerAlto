function Move-PaSecurityPolicy {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ParameterSetName = "name-before", Mandatory = $True, Position = 0)]
        [Parameter(ParameterSetName = "name-after", Mandatory = $True, Position = 0)]
        [Parameter(ParameterSetName = "name-top", Mandatory = $True, Position = 0)]
        [Parameter(ParameterSetName = "name-bottom", Mandatory = $True, Position = 0)]
        [string]$Name,

        [Parameter(ParameterSetName = "paobject-before", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [Parameter(ParameterSetName = "paobject-after", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [Parameter(ParameterSetName = "paobject-top", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [Parameter(ParameterSetName = "paobject-bottom", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [PaSecurityPolicy]$PaSecurityPolicy,

        [Parameter(ParameterSetName = "name-before", Mandatory = $True)]
        [Parameter(ParameterSetName = "paobject-before", Mandatory = $True)]
        [string]$Before,

        [Parameter(ParameterSetName = "name-after", Mandatory = $True)]
        [Parameter(ParameterSetName = "paobject-after", Mandatory = $True)]
        [string]$After,

        [Parameter(ParameterSetName = "name-top", Mandatory = $True)]
        [Parameter(ParameterSetName = "paobject-top", Mandatory = $True)]
        [switch]$Top,

        [Parameter(ParameterSetName = "name-bottom", Mandatory = $True)]
        [Parameter(ParameterSetName = "paobject-bottom", Mandatory = $True)]
        [switch]$Bottom
    )

    BEGIN {
    }

    PROCESS {
        switch ($PsCmdlet.ParameterSetName) {
            { $_ -match 'name' } {
                $ConfigObject = [PaSecurityPolicy]::new($Name)
                continue
            }
            { $_ -match 'paobject' } {
                $ConfigObject = $PaSecurityPolicy
                continue
            }
        }

        switch ($PsCmdlet.ParameterSetName) {
            { $_ -match 'before' } {
                $Where = "before&dst=$Before"
                continue
            }
            { $_ -match 'after' } {
                $Where = "after&dst=$After"
                continue
            }
            { $_ -match 'top' } {
                $Where = 'top'
                continue
            }
            { $_ -match 'bottom' } {
                $Where = 'bottom'
                continue
            }
        }


        $Xpath = $Global:PaDeviceObject.createXPath('rulebase/security/rules', $ConfigObject.Name)

        if ($PSCmdlet.ShouldProcess("Creating new rule: $($ConfigObject.Name)")) {
            $Set = Invoke-PaApiConfig -Move -Xpath $XPath -Location $Where

            $Set
        }
    }
}