function Set-PaUrlCategory {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        # paobject
        [Parameter(ParameterSetName = "paobject", Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [PaUrlCategory]$PaUrlCategory,

        # manual
        [Parameter(ParameterSetName = "manual", Mandatory = $True, Position = 0)]
        [Parameter(ParameterSetName = "replace", Mandatory = $True, Position = 0)]
        [string]$Name,

        [Parameter(ParameterSetName = "manual", Mandatory = $False, Position = 1)]
        [Parameter(ParameterSetName = "replace", Mandatory = $True, Position = 1)]
        [string[]]$Members,

        [Parameter(ParameterSetName = "manual", Mandatory = $False, Position = 2)]
        [string]$Description,

        [Parameter(ParameterSetName = "replace", Mandatory = $True)]
        [switch]$ReplaceMembers
    )

    BEGIN {
        $ConfigNode = 'profiles/custom-url-category'
        $ResponseNode = 'custom-url-category'
        $VerbosePrefix = 'Set-PaUrlCategory:'
    }

    PROCESS {
        $InvokeParams = @{}

        Write-Verbose "$VerbosePrefix ParameterSetName: $($PsCmdlet.ParameterSetName)"
        switch ($PsCmdlet.ParameterSetName) {
            'paobject' {
                $ConfigObject = $PaUrlCategory
                $XPath = $Global:PaDeviceObject.createXPath($ConfigNode, $ConfigObject.Name)
                $InvokeParams.Set = $true
                continue
            }
            { ($_ -eq 'manual') -or
                ($_ -eq 'replace') } {

                $ConfigObject = [PaUrlCategory]::new($Name)
                $XPath = $Global:PaDeviceObject.createXPath($ConfigNode, $Name)

                if ($Description) {
                    $ConfigObject.Description = $Description
                }

                $ConfigObject.Members = $Members

                if ($ReplaceMembers) {
                    $InvokeParams.Edit = $true
                    $XPath += '/list'
                } else {
                    $InvokeParams.Set = $true
                }
                continue
            }
        }

        $InvokeParams.XPath = $XPath
        $InvokeParams.Element = $ConfigObject.ToXml().$ResponseNode.entry.InnerXml

        $global:InvokeParams = $InvokeParams

        if ($PSCmdlet.ShouldProcess("Creating new Url Category: $($ConfigObject.Name)")) {
            $Set = Invoke-PaApiConfig @InvokeParams

            $Set
        }
    }
}