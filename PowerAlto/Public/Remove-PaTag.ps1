function Remove-PaTag {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ParameterSetName = "name", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [string]$Name,

        [Parameter(ParameterSetName = "paobject", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [PaTag]$PaTag
    )

    BEGIN {
    }

    PROCESS {
        switch ($PsCmdlet.ParameterSetName) {
            'name' {
                $ConfigObject = [PaTag]::new($Name)
                continue
            }
            'paobject' {
                $ConfigObject = $PaTag
                continue
            }
        }

        $Xpath = $Global:PaDeviceObject.createXPath('tag', $ConfigObject.Name)

        if ($PSCmdlet.ShouldProcess("Creating new rule: $($ConfigObject.Name)")) {
            $Delete = Invoke-PaApiConfig -Delete -Xpath $XPath

            $Delete
        }
    }
}