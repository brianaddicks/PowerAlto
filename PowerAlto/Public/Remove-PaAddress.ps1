function Remove-PaAddress {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ParameterSetName = "name", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [string]$Name,

        [Parameter(ParameterSetName = "paobject", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [PaAddress]$PaAddress
    )

    BEGIN {
    }

    PROCESS {
        switch ($PsCmdlet.ParameterSetName) {
            'name' {
                $ConfigObject = [PaAddress]::new($Name)
                continue
            }
            'paobject' {
                $ConfigObject = $PaAddress
                continue
            }
        }

        $Xpath = $Global:PaDeviceObject.createXPath('address', $ConfigObject.Name)

        if ($PSCmdlet.ShouldProcess("Creating new rule: $($ConfigObject.Name)")) {
            $Delete = Invoke-PaApiConfig -Delete -Xpath $XPath

            $Delete
        }
    }
}