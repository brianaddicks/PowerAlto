function Set-PaSecurityPolicy {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ParameterSetName = "name", Mandatory = $True, Position = 0)]
        [string]$Name,

        [Parameter(ParameterSetName = "paobject", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [PaSecurityPolicy]$PaSecurityPolicy,

        [Parameter(Mandatory = $False)]
        [string[]]$SourceZone,

        [Parameter(Mandatory = $False)]
        [string[]]$SourceUser,

        [Parameter(Mandatory = $False)]
        [string[]]$DestinationZone,

        [Parameter(Mandatory = $False)]
        [string[]]$DestinationAddress,

        [Parameter(Mandatory = $False)]
        [ValidateSet('allow', 'deny')]
        [string]$Action
    )

    BEGIN {
    }

    PROCESS {
        switch ($PsCmdlet.ParameterSetName) {
            'name' {
                $ConfigObject = [PaSecurityPolicy]::new($Name)
                continue
            }
            'paobject' {
                $ConfigObject = $PaSecurityPolicy
                continue
            }
        }

        if ($SourceZone) {
            $ConfigObject.SourceZone = $SourceZone
        }

        if ($SourceUser) {
            $ConfigObject.SourceUser = $SourceUser
        }

        if ($DestinationZone) {
            $ConfigObject.DestinationZone = $DestinationZone
        }

        if ($DestinationAddress) {
            $ConfigObject.DestinationAddress = $DestinationAddress
        }

        if ($Action) {
            $ConfigObject.Action = $Action
        }

        $ElementXml = $ConfigObject.ToXml().rules.entry.InnerXml
        $Xpath = $Global:PaDeviceObject.createXPath('rulebase/security/rules', $ConfigObject.Name)
        $Global:test = $ConfigObject

        if ($PSCmdlet.ShouldProcess("Creating new rule: $($ConfigObject.Name)")) {
            $Set = Invoke-PaApiConfig -Set -Xpath $XPath -Element $ElementXml

            $Set
        }
    }
}