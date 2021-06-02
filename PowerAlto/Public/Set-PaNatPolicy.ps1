function Set-PaNatPolicy {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ValueFromPipeline, ParameterSetName = "ClassObject", Mandatory = $True, Position = 0)]
        [PaNatPolicy]$PaNatPolicy
    )

    BEGIN {

    }

    PROCESS {

        switch ($PsCmdlet.ParameterSetName) {
            'name' {
            }
            'ClassObject' {
                $ConfigObject = $PaNatPolicy
                continue
            }
        }


        $ConfigNode = $ConfigObject::ConfigNode
        $ElementXml = $ConfigObject.ToXml().rules.entry.InnerXml
        $Xpath = $Global:PaDeviceObject.createXPath($ConfigNode, $ConfigObject.Name)

        if ($PSCmdlet.ShouldProcess("Creating new Tag: $($ConfigObject.Name)")) {
            $Set = Invoke-PaApiConfig -Set -Xpath $XPath -Element $ElementXml

            $Set
        }
    }
}