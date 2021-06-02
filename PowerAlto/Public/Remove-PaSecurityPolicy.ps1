function Remove-PaSecurityPolicy {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ParameterSetName = "name", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [string]$Name,

        [Parameter(ParameterSetName = "paobject", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [PaSecurityPolicy]$PaSecurityPolicy
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

        $Xpath = $Global:PaDeviceObject.createXPath('rulebase/security/rules', $ConfigObject.Name)

        if ($PSCmdlet.ShouldProcess("Creating new rule: $($ConfigObject.Name)")) {
            $Delete = Invoke-PaApiConfig -Delete -Xpath $XPath

            $Delete
        }
    }
}