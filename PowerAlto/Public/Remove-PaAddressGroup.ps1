function Remove-PaAddressGroup {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ParameterSetName = "name", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [string]$Name,

        [Parameter(ParameterSetName = "paobject", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [PaAddressGroup]$PaAddressGroup
    )

    BEGIN {
    }

    PROCESS {
        switch ($PsCmdlet.ParameterSetName) {
            'name' {
                $ConfigObject = [PaAddressGroup]::new($Name)
                continue
            }
            'paobject' {
                $ConfigObject = $PaAddressGroup
                continue
            }
        }

        $Xpath = $Global:PaDeviceObject.createXPath('address-group', $ConfigObject.Name)

        if ($PSCmdlet.ShouldProcess("Creating new rule: $($ConfigObject.Name)")) {
            $Delete = Invoke-PaApiConfig -Delete -Xpath $XPath

            $Delete
        }
    }
}