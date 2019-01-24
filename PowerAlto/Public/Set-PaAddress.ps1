function Set-PaAddress {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ParameterSetName = "name", Mandatory = $True, Position = 0)]
        [string]$Name,

        [Parameter(ValueFromPipeline, ParameterSetName = "paaddress", Mandatory = $True, Position = 0)]
        [PaAddress]$PaAddress,

        [Parameter(ParameterSetName = "name", Mandatory = $True)]
        [Parameter(ParameterSetName = "paaddress", Mandatory = $False)]
        [ValidateSet('ip-netmask', 'ip-range', 'fqdn')]
        [string]$Type,

        [Parameter(ParameterSetName = "name", Mandatory = $True)]
        [Parameter(ParameterSetName = "paaddress", Mandatory = $False)]
        [string]$Value,

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
            'name' {
                $ConfigObject = [PaAddress]::new($Name)
                continue
            }
            'paaddress' {
                $ConfigObject = $PaAddress
                continue
            }
        }

        $ShouldProcessMessage += "Modifying object`r`n"

        if ($Description) {
            $ConfigObject.Description = $Description
            $ShouldProcessMessage += "Description: $Description`r`n"
        }

        if ($Type) {
            $ConfigObject.Type = $Type
            $ShouldProcessMessage += "Type: $Type`r`n"
        }
        if ($Tag) {
            if (($ConfigObject.Tags.Count -gt 0) -and ($ConfigObject.Tags[0] -eq '')) {
                $ConfigObject.Tags = $Tag
            } else {
                $ConfigObject.Tags += $Tag
            }

            $ShouldProcessMessage += "Tags: $($ConfigObject.Tags -join ',')`r`n"
        }

        #
        switch ($Type) {
            'ip-netmask' {
                $ConfigObject.Value = [HelperRegex]::isIpv4($Value, "IpNetmask must be a valid CIDR range or Ip Address. Ex: 10.0.0.0/16")
            }
            'ip-range' {
                $ConfigObject.Value = [HelperRegex]::isIpv4Range($Value, "IpRange must be a valid Ip Range. Ex: 192.168.1.1-192.168.1.250")
            }
            'fqdn' {
                $ConfigObject.Value = [HelperRegex]::isFqdn($Value, "Fqdn must be a valid Fully Qualified Domain Name. Ex: contoso.com")
            }
        }

        $ShouldProcessMessage += "Value: $Value`r`n"

        $ElementXml = $ConfigObject.ToXml().address.entry.InnerXml
        $Xpath = $Global:PaDeviceObject.createXPath('address', $ConfigObject.Name)
        $ShouldProcessMessage += "XPath: $XPath"

        if ($PSCmdlet.ShouldProcess($ShouldProcessMessage)) {
            $Set = Invoke-PaApiConfig -Set -Xpath $XPath -Element $ElementXml

            $Set
        }
    }
}