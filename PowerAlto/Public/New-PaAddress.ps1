function New-PaAddress {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ParameterSetName = "name", Mandatory = $True, Position = 0)]
        [string]$Name,

        [Parameter(ParameterSetName = "name", Mandatory = $False)]
        [string]$Description,

        [Parameter(ParameterSetName = "name", Mandatory = $False)]
        [ValidateSet('Fqdn', 'IpNetmask', 'IpRange')]
        [string]$Type,

        [Parameter(ParameterSetName = "name", Mandatory = $False)]
        [string]$Value,

        [Parameter(ParameterSetName = "name", Mandatory = $False)]
        [string[]]$Tag
    )

    Begin {
        $VerbosePrefix = "New-PaAddress:"

        # type map
        $TypeMap = @{
            Fqdn      = 'fqdn'
            IpNetmask = 'ip-netmask'
            IpRange   = 'ip-range'
        }

        $ReturnObject = [PaAddress]::new($Name)
        $ReturnObject.Description = $Description
        $ReturnObject.Value = $Value
        $ReturnObject.Tags = $Tag

        if ($Type) {
            $ReturnObject.Type = $TypeMap.$Type
        }
    }

    Process {
    }

    End {
        $ReturnObject
    }
}