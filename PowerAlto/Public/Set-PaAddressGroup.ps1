function Set-PaAddressGroup {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ParameterSetName = "name-member", Mandatory = $True, Position = 0)]
        [Parameter(ParameterSetName = "name-filter", Mandatory = $True, Position = 0)]
        [string]$Name,

        [Parameter(ValueFromPipeline, ParameterSetName = "object-member", Mandatory = $True, Position = 0)]
        [Parameter(ValueFromPipeline, ParameterSetName = "object-filter", Mandatory = $True, Position = 0)]
        [PaAddressGroup]$PaAddressGroup,

        [Parameter(ParameterSetName = "name-filter", Mandatory = $True)]
        [Parameter(ParameterSetName = "object-filter", Mandatory = $False)]
        [string]$Filter,

        [Parameter(ParameterSetName = "name-member", Mandatory = $True)]
        [Parameter(ParameterSetName = "object-member", Mandatory = $False)]
        [string]$Member,

        [Parameter(Mandatory = $False)]
        [string]$Description,

        [Parameter(Mandatory = $False)]
        [string[]]$Tag
    )

    BEGIN {
    }

    PROCESS {
        $ShouldProcessMessage = "`r`n"

        switch ($PsCmdlet.ParameterSetName) {
            { $_ -match 'name' } {
                Write-Verbose 'Name'
                $ConfigObject = [PaAddressGroup]::new($Name)
                continue
            }
            { $_ -match 'object' } {
                $ConfigObject = $PaAddressGroup
                continue
            }
        }

        $ShouldProcessMessage += "Modifying object`r`n"

        if ($Description) {
            $ConfigObject.Description = $Description
            $ShouldProcessMessage += "Description: $Description`r`n"
        }

        if ($Tag) {
            if (($ConfigObject.Tags.Count -gt 0) -and ($ConfigObject.Tags[0] -eq '')) {
                $ConfigObject.Tags = $Tag
            } else {
                $ConfigObject.Tags += $Tag
            }

            $ShouldProcessMessage += "Tags: $($ConfigObject.Tags -join ',')`r`n"
        }

        if ($Filter) {
            $ConfigObject.Type = 'dynamic'
            $ConfigObject.Filter = $Filter
        }

        if ($Member) {
            $ConfigObject.Type = 'static'
            $ConfigObject.Member = $Member
        }

        $ShouldProcessMessage += "Value: $Value`r`n"

        $ElementXml = $ConfigObject.ToXml().'address-group'.entry.InnerXml
        $Xpath = $Global:PaDeviceObject.createXPath('address-group', $ConfigObject.Name)
        $ShouldProcessMessage += "XPath: $XPath"

        if ($PSCmdlet.ShouldProcess($ShouldProcessMessage)) {
            $Set = Invoke-PaApiConfig -Set -Xpath $XPath -Element $ElementXml

            $Set
        }
    }
}